// Chat Provider - State management for SilverAgent Super App
// Manages messages, conversations, LLM integration, and agentic tool calling

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../services/llama_service.dart';
import '../services/mcp_service.dart';
import '../utils/response_parser.dart';

class ChatProvider with ChangeNotifier {
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _connectionError;

  // Services
  late final LlamaService _llamaService;
  late final McpService _mcpService;
  bool _servicesInitialized = false;

  // Conversation history for LLM context
  final List<Map<String, String>> _conversationHistory = [];

  // Pending tool call awaiting user approval
  ToolCallData? _pendingToolCall;
  String? _pendingToolCallMessageId;

  // Pending decline context - to be sent with user's next message
  String? _pendingDeclineContext;

  // Getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get activeConversationId => _activeConversationId;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get connectionError => _connectionError;
  bool get servicesInitialized => _servicesInitialized;
  bool get hasPendingToolCall => _pendingToolCall != null;
  bool get hasPendingDecline => _pendingDeclineContext != null;
  bool get isNewConversation =>
      _messages.length <= 1 && _activeConversationId == null;

  // Quick actions for the super app
  final List<QuickAction> quickActions = [
    QuickAction(
      id: '1',
      label: 'Book Grab',
      sublabel: 'Ride booking',
      icon: 'directions_car',
      prompt: 'I need to book a Grab ride',
    ),
    QuickAction(
      id: '2',
      label: 'Healthcare',
      sublabel: 'NUH appointments',
      icon: 'local_hospital',
      prompt: 'I need to see a doctor',
    ),
    QuickAction(
      id: '3',
      label: 'Weather',
      sublabel: 'Current conditions',
      icon: 'wb_sunny',
      prompt: "What's the weather like today?",
    ),
    QuickAction(
      id: '4',
      label: 'Help Me',
      sublabel: 'General assistance',
      icon: 'help_outline',
      prompt: 'I need help with something',
    ),
  ];

  ChatProvider() {
    _llamaService = LlamaService();
    _mcpService = McpService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    debugPrint('Initializing SilverAgent services...');

    // Initialize llama service
    await _llamaService.initialize();
    _isConnected = _llamaService.isConnected;

    if (!_isConnected) {
      _connectionError = 'Llama server not connected. Please start llama-server at localhost:8080';
    }

    // Initialize MCP servers
    try {
      await _mcpService.initialize();
      debugPrint('MCP services initialized with tools: ${_mcpService.availableTools}');
    } catch (e) {
      debugPrint('MCP initialization error: $e');
    }

    _servicesInitialized = true;

    // Create welcome message
    _messages = [_createWelcomeMessage()];
    notifyListeners();
  }

  Message _createWelcomeMessage() {
    final connectionStatus = _isConnected
        ? "I'm connected and ready to help!"
        : "Note: LLM server not connected. Please start llama-server.";

    return Message(
      id: const Uuid().v4(),
      content:
          "Hello! I'm SilverAgent, your Singapore super assistant. 🇸🇬\n\n"
          "I can help you with:\n"
          "• Booking Grab rides\n"
          "• Managing healthcare appointments\n"
          "• Checking the weather\n"
          "• And more!\n\n"
          "$connectionStatus",
      role: 'assistant',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  void startNewConversation() {
    _activeConversationId = null;
    _messages = [_createWelcomeMessage()];
    _conversationHistory.clear();
    _pendingToolCall = null;
    _pendingToolCallMessageId = null;
    _pendingDeclineContext = null;
    notifyListeners();
  }

  void selectConversation(String id) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == id,
      orElse: () => _conversations.first,
    );

    _activeConversationId = id;
    _messages = List.from(conversation.messages);
    _rebuildConversationHistory();
    notifyListeners();
  }

  void _rebuildConversationHistory() {
    _conversationHistory.clear();
    for (final message in _messages) {
      if (message.type == MessageType.text) {
        _conversationHistory.add({
          'role': message.role,
          'content': message.content,
        });
      }
    }
  }

  /// Send a user message and get LLM response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      role: 'user',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    _messages.add(userMessage);

    // If there's a pending decline, include it with the user's message
    if (_pendingDeclineContext != null) {
      // Combine decline context with user's message
      final combinedContent = '$_pendingDeclineContext\n\nUser says: $content';
      _conversationHistory.add({'role': 'user', 'content': combinedContent});
      _pendingDeclineContext = null;
    } else {
      _conversationHistory.add({'role': 'user', 'content': content});
    }

    _isLoading = true;
    notifyListeners();

    // Create conversation if new
    if (_activeConversationId == null) {
      final newConv = Conversation(
        id: const Uuid().v4(),
        title: _generateTitle(content),
        preview: content,
        timestamp: DateTime.now(),
        status: ConversationStatus.active,
        messages: List.from(_messages),
      );
      _conversations.insert(0, newConv);
      _activeConversationId = newConv.id;
    }

    // Get LLM response
    await _getLlmResponse();
  }

  /// Get response from LLM and handle tool calls
  Future<void> _getLlmResponse() async {
    // Message IDs for dynamic updates
    final thinkingMessageId = const Uuid().v4();
    final streamingMessageId = const Uuid().v4();

    // State for incremental parsing
    bool isInStrategy = false;
    bool thinkingMessageAdded = false;
    final rawBuffer = StringBuffer();

    try {
      await for (final chunk in _llamaService.streamChatCompletion(_conversationHistory)) {
        rawBuffer.write(chunk);
        final currentRaw = rawBuffer.toString();

        // Check if we've entered a strategy block
        if (!isInStrategy && currentRaw.contains('<strategy>')) {
          isInStrategy = true;

          // Add thinking message immediately
          if (!thinkingMessageAdded) {
            _messages.add(Message(
              id: thinkingMessageId,
              content: '',
              role: 'assistant',
              timestamp: DateTime.now(),
              type: MessageType.thinking,
              isStreaming: true,
              metadata: MessageMetadata(
                thinking: ThinkingData(content: ''),
              ),
            ));
            thinkingMessageAdded = true;
            notifyListeners();
          }
        }

        // Stream thinking content while inside strategy block
        if (isInStrategy && thinkingMessageAdded) {
          // Extract content after <strategy> tag
          final strategyStart = currentRaw.indexOf('<strategy>');
          if (strategyStart != -1) {
            var thinkingContent = currentRaw.substring(strategyStart + 10); // After '<strategy>'

            // Remove closing tag if present
            final endTagIndex = thinkingContent.indexOf('</strategy>');
            if (endTagIndex != -1) {
              thinkingContent = thinkingContent.substring(0, endTagIndex);
            }
            thinkingContent = thinkingContent.trim();

            // Update thinking message, preserving isExpanded state
            final thinkingIndex = _messages.indexWhere((m) => m.id == thinkingMessageId);
            if (thinkingIndex != -1) {
              final existingExpanded = _messages[thinkingIndex].metadata?.thinking?.isExpanded ?? false;
              _messages[thinkingIndex] = _messages[thinkingIndex].copyWith(
                content: thinkingContent,
                metadata: MessageMetadata(
                  thinking: ThinkingData(
                    content: thinkingContent,
                    isExpanded: existingExpanded,
                  ),
                ),
              );
              notifyListeners();
            }
          }
        }

        // Check if strategy block is complete
        if (isInStrategy && currentRaw.contains('</strategy>')) {
          isInStrategy = false;

          // Mark thinking as no longer streaming
          final thinkingIndex = _messages.indexWhere((m) => m.id == thinkingMessageId);
          if (thinkingIndex != -1) {
            final existingExpanded = _messages[thinkingIndex].metadata?.thinking?.isExpanded ?? false;
            final existingContent = _messages[thinkingIndex].metadata?.thinking?.content ?? '';
            _messages[thinkingIndex] = _messages[thinkingIndex].copyWith(
              isStreaming: false,
              metadata: MessageMetadata(
                thinking: ThinkingData(
                  content: existingContent,
                  isExpanded: existingExpanded,
                ),
              ),
            );
            notifyListeners();
          }
        }

        // Extract visible text (everything outside <strategy> and <tool_call> tags)
        var visibleText = currentRaw;
        // Remove complete strategy blocks
        visibleText = visibleText.replaceAll(RegExp(r'<strategy>[\s\S]*?</strategy>'), '');
        // Remove incomplete strategy blocks (opening tag but no closing)
        visibleText = visibleText.replaceAll(RegExp(r'<strategy>[\s\S]*$'), '');
        // Remove complete tool_call blocks
        visibleText = visibleText.replaceAll(RegExp(r'<tool_call>[\s\S]*?</tool_call>'), '');
        // Remove incomplete tool_call blocks
        visibleText = visibleText.replaceAll(RegExp(r'<tool_call>[\s\S]*$'), '');
        // Remove any trailing partial tag (like "<str" or "<tool_c" that hasn't completed)
        // This catches text ending with < followed by letters
        visibleText = visibleText.replaceAll(RegExp(r'<[a-zA-Z_/]*$'), '');
        visibleText = visibleText.trim();

        // Update or add streaming message for visible text
        if (visibleText.isNotEmpty) {
          final streamingIndex = _messages.indexWhere((m) => m.id == streamingMessageId);
          if (streamingIndex == -1) {
            // Add streaming message
            _messages.add(Message(
              id: streamingMessageId,
              content: visibleText,
              role: 'assistant',
              timestamp: DateTime.now(),
              type: MessageType.text,
              isStreaming: true,
            ));
          } else {
            // Update existing streaming message
            _messages[streamingIndex] = _messages[streamingIndex].copyWith(content: visibleText);
          }
          notifyListeners();
        }
      }

      final fullResponse = rawBuffer.toString();

      // Remove streaming message (we'll re-add as final)
      _messages.removeWhere((m) => m.id == streamingMessageId);
      // Remove temporary thinking message (will be replaced with parsed one if present)
      _messages.removeWhere((m) => m.id == thinkingMessageId);

      // Parse the full response for final messages
      final segments = ResponseParser.parse(fullResponse);
      final parsedMessages = ResponseParser.toMessages(segments);

      // Add assistant response to conversation history BEFORE processing tool calls
      // This ensures the model sees its own response when auto-execute triggers recursively
      final plainText = ResponseParser.extractPlainText(fullResponse);
      if (plainText.isNotEmpty || ResponseParser.hasToolCall(fullResponse)) {
        _conversationHistory.add({'role': 'assistant', 'content': fullResponse});
      }

      // Add parsed messages to chat
      for (final msg in parsedMessages) {
        _messages.add(msg);

        // Check if this is a tool call
        if (msg.type == MessageType.toolCall && msg.metadata?.toolCall != null) {
          final toolCall = msg.metadata!.toolCall!;

          // Check if this tool is auto-approved (e.g., weather tools)
          if (_mcpService.isAutoApproved(toolCall.name)) {
            // Auto-execute without user approval
            toolCall.isAutoExecuted = true;
            await _autoExecuteToolCall(toolCall, msg.id);
          } else {
            // Requires manual approval
            _pendingToolCall = toolCall;
            _pendingToolCallMessageId = msg.id;
          }
        }
      }

      _updateConversation();

    } catch (e) {
      debugPrint('LLM response error: $e');
      _messages.removeWhere((m) => m.id == streamingMessageId);
      _messages.removeWhere((m) => m.id == thinkingMessageId);
      _messages.add(Message(
        id: const Uuid().v4(),
        content: 'Sorry, I encountered an error: $e',
        role: 'assistant',
        timestamp: DateTime.now(),
        type: MessageType.text,
        status: MessageStatus.error,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accept a pending tool call
  Future<void> acceptToolCall() async {
    if (_pendingToolCall == null) return;

    final toolCall = _pendingToolCall!;
    final messageId = _pendingToolCallMessageId;

    // Update tool call status
    toolCall.status = ToolCallStatus.executing;
    _updateToolCallMessage(messageId!, toolCall);
    _isLoading = true;
    notifyListeners();

    try {
      // Execute the tool via MCP
      final result = await _mcpService.executeTool(toolCall.name, toolCall.arguments);

      // Check if the result contains an error
      if (result.containsKey('error')) {
        toolCall.status = ToolCallStatus.error;
        toolCall.error = result['error'].toString();
        _updateToolCallMessage(messageId, toolCall);
        _pendingToolCall = null;
        _pendingToolCallMessageId = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Update tool call with result
      toolCall.status = ToolCallStatus.completed;
      toolCall.result = result;
      _updateToolCallMessage(messageId, toolCall);

      // Add tool result message
      final resultMessage = Message(
        id: const Uuid().v4(),
        content: ResponseParser.formatToolResult(toolCall.name, result),
        role: 'system',
        timestamp: DateTime.now(),
        type: MessageType.toolResult,
        metadata: MessageMetadata(toolResult: result),
      );
      _messages.add(resultMessage);

      // Add to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': ResponseParser.formatToolResult(toolCall.name, result),
      });

      // Clear pending tool call
      _pendingToolCall = null;
      _pendingToolCallMessageId = null;

      notifyListeners();

      // Auto-trigger next LLM turn (agentic loop)
      await _getLlmResponse();

    } catch (e) {
      debugPrint('Tool execution error: $e');
      toolCall.status = ToolCallStatus.error;
      toolCall.error = e.toString();
      _updateToolCallMessage(messageId, toolCall);
      _pendingToolCall = null;
      _pendingToolCallMessageId = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Decline a pending tool call - waits for user to provide alternative instructions
  Future<void> declineToolCall() async {
    if (_pendingToolCall == null) return;

    final toolCall = _pendingToolCall!;
    final messageId = _pendingToolCallMessageId;

    // Update tool call status (the tool card will show declined state)
    toolCall.status = ToolCallStatus.declined;
    _updateToolCallMessage(messageId!, toolCall);

    // Store decline context to be sent with user's next message
    _pendingDeclineContext = ResponseParser.formatDeclineMessage(toolCall.name);

    // Clear pending tool call
    _pendingToolCall = null;
    _pendingToolCallMessageId = null;

    notifyListeners();
    // Don't auto-trigger LLM - wait for user's input
  }

  /// Auto-execute a tool call (for auto-approved tools like weather)
  Future<void> _autoExecuteToolCall(ToolCallData toolCall, String messageId) async {
    toolCall.status = ToolCallStatus.executing;
    _updateToolCallMessage(messageId, toolCall);
    notifyListeners();

    try {
      final result = await _mcpService.executeTool(toolCall.name, toolCall.arguments);

      // Check if the result contains an error
      if (result.containsKey('error')) {
        toolCall.status = ToolCallStatus.error;
        toolCall.error = result['error'].toString();
        _updateToolCallMessage(messageId, toolCall);
        notifyListeners();
        return;
      }

      toolCall.status = ToolCallStatus.completed;
      toolCall.result = result;
      _updateToolCallMessage(messageId, toolCall);

      // Add to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': ResponseParser.formatToolResult(toolCall.name, result),
      });

      notifyListeners();

      // Continue the agentic loop
      await _getLlmResponse();

    } catch (e) {
      debugPrint('Auto tool execution error: $e');
      toolCall.status = ToolCallStatus.error;
      toolCall.error = e.toString();
      _updateToolCallMessage(messageId, toolCall);
      notifyListeners();
    }
  }

  void _updateToolCallMessage(String messageId, ToolCallData toolCall) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        metadata: MessageMetadata(toolCall: toolCall),
      );
    }
  }

  void _updateConversation() {
    if (_activeConversationId != null) {
      final index = _conversations.indexWhere(
        (c) => c.id == _activeConversationId,
      );
      if (index != -1) {
        final lastMessage = _messages.lastWhere(
          (m) => m.type == MessageType.text && m.role == 'assistant',
          orElse: () => _messages.last,
        );
        final preview = lastMessage.content.length > 50
            ? '${lastMessage.content.substring(0, 50)}...'
            : lastMessage.content;

        _conversations[index] = Conversation(
          id: _conversations[index].id,
          title: _conversations[index].title,
          preview: preview,
          timestamp: _conversations[index].timestamp,
          status: ConversationStatus.active,
          messages: List.from(_messages),
        );
      }
    }
  }

  String _generateTitle(String firstMessage) {
    if (firstMessage.toLowerCase().contains('grab') ||
        firstMessage.toLowerCase().contains('ride')) {
      return 'Grab Booking';
    } else if (firstMessage.toLowerCase().contains('doctor') ||
        firstMessage.toLowerCase().contains('appointment') ||
        firstMessage.toLowerCase().contains('hospital')) {
      return 'Healthcare Query';
    } else if (firstMessage.toLowerCase().contains('weather')) {
      return 'Weather Check';
    } else {
      return firstMessage.length > 30
          ? '${firstMessage.substring(0, 30)}...'
          : firstMessage;
    }
  }

  /// Toggle thinking block expansion
  void toggleThinkingExpanded(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _messages[index].metadata?.thinking != null) {
      final thinking = _messages[index].metadata!.thinking!;
      thinking.isExpanded = !thinking.isExpanded;
      notifyListeners();
    }
  }

  /// Toggle tool result expansion
  void toggleToolResultExpanded(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _messages[index].metadata?.toolCall != null) {
      final toolCall = _messages[index].metadata!.toolCall!;
      toolCall.isResultExpanded = !toolCall.isResultExpanded;
      notifyListeners();
    }
  }

  /// Retry connection to llama server
  Future<void> retryConnection() async {
    _connectionError = null;
    notifyListeners();

    _isConnected = await _llamaService.checkConnection();
    if (!_isConnected) {
      _connectionError = 'Llama server not connected. Please start llama-server at localhost:8080';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _mcpService.dispose();
    super.dispose();
  }
}
