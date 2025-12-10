// Chat models for SilverAgent Super App

/// Message types for different content in the chat
enum MessageType {
  text,        // Regular text message
  thinking,    // Strategy/thinking block
  toolCall,    // Tool call awaiting approval
  toolResult,  // Result from a tool execution
  systemMessage, // System notification
}

/// Status of a tool call
enum ToolCallStatus {
  pending,    // Awaiting user approval
  accepted,   // User accepted, executing
  declined,   // User declined
  executing,  // Currently running
  completed,  // Successfully completed
  error,      // Failed with error
}

enum MessageStatus { pending, success, error, retrying }

enum ConversationStatus { active, completed, pending, error }

/// Represents a tool call extracted from LLM output
class ToolCallData {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  ToolCallStatus status;
  Map<String, dynamic>? result;
  String? error;
  bool isAutoExecuted; // True if auto-approved (e.g., weather tools)
  bool isResultExpanded; // For UI - whether result is expanded

  ToolCallData({
    required this.id,
    required this.name,
    required this.arguments,
    this.status = ToolCallStatus.pending,
    this.result,
    this.error,
    this.isAutoExecuted = false,
    this.isResultExpanded = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arguments': arguments,
    'status': status.name,
    if (result != null) 'result': result,
    if (error != null) 'error': error,
    'isAutoExecuted': isAutoExecuted,
    'isResultExpanded': isResultExpanded,
  };

  factory ToolCallData.fromJson(Map<String, dynamic> json) => ToolCallData(
    id: json['id'] as String,
    name: json['name'] as String,
    arguments: Map<String, dynamic>.from(json['arguments'] ?? {}),
    status: ToolCallStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ToolCallStatus.pending,
    ),
    result: json['result'] as Map<String, dynamic>?,
    error: json['error'] as String?,
    isAutoExecuted: json['isAutoExecuted'] as bool? ?? false,
    isResultExpanded: json['isResultExpanded'] as bool? ?? false,
  );

  ToolCallData copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? arguments,
    ToolCallStatus? status,
    Map<String, dynamic>? result,
    String? error,
    bool? isAutoExecuted,
    bool? isResultExpanded,
  }) => ToolCallData(
    id: id ?? this.id,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    status: status ?? this.status,
    result: result ?? this.result,
    error: error ?? this.error,
    isAutoExecuted: isAutoExecuted ?? this.isAutoExecuted,
    isResultExpanded: isResultExpanded ?? this.isResultExpanded,
  );
}

/// Represents thinking/strategy content from LLM
class ThinkingData {
  final String content;
  bool isExpanded;

  ThinkingData({
    required this.content,
    this.isExpanded = false,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'isExpanded': isExpanded,
  };

  factory ThinkingData.fromJson(Map<String, dynamic> json) => ThinkingData(
    content: json['content'] as String,
    isExpanded: json['isExpanded'] as bool? ?? false,
  );
}

/// Metadata for different message types
class MessageMetadata {
  final ToolCallData? toolCall;
  final ThinkingData? thinking;
  final Map<String, dynamic>? toolResult;
  final String? systemMessageType;

  MessageMetadata({
    this.toolCall,
    this.thinking,
    this.toolResult,
    this.systemMessageType,
  });

  Map<String, dynamic> toJson() => {
    if (toolCall != null) 'toolCall': toolCall!.toJson(),
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (toolResult != null) 'toolResult': toolResult,
    if (systemMessageType != null) 'systemMessageType': systemMessageType,
  };

  factory MessageMetadata.fromJson(Map<String, dynamic> json) => MessageMetadata(
    toolCall: json['toolCall'] != null
        ? ToolCallData.fromJson(json['toolCall'])
        : null,
    thinking: json['thinking'] != null
        ? ThinkingData.fromJson(json['thinking'])
        : null,
    toolResult: json['toolResult'] as Map<String, dynamic>?,
    systemMessageType: json['systemMessageType'] as String?,
  );
}

class Message {
  final String id;
  final String content;
  final String role; // 'user', 'assistant', or 'system'
  final DateTime timestamp;
  final MessageType type;
  final bool isTyping;
  final bool isStreaming;
  final MessageStatus? status;
  final MessageMetadata? metadata;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.type = MessageType.text,
    this.isTyping = false,
    this.isStreaming = false,
    this.status,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'isTyping': isTyping,
    'isStreaming': isStreaming,
    'status': status?.name,
    'metadata': metadata?.toJson(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['content'] as String,
    role: json['role'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    type: MessageType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => MessageType.text,
    ),
    isTyping: json['isTyping'] as bool? ?? false,
    isStreaming: json['isStreaming'] as bool? ?? false,
    status: json['status'] != null
        ? MessageStatus.values.firstWhere(
            (s) => s.name == json['status'],
            orElse: () => MessageStatus.pending,
          )
        : null,
    metadata: json['metadata'] != null
        ? MessageMetadata.fromJson(json['metadata'])
        : null,
  );

  Message copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    MessageType? type,
    bool? isTyping,
    bool? isStreaming,
    MessageStatus? status,
    MessageMetadata? metadata,
  }) => Message(
    id: id ?? this.id,
    content: content ?? this.content,
    role: role ?? this.role,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    isTyping: isTyping ?? this.isTyping,
    isStreaming: isStreaming ?? this.isStreaming,
    status: status ?? this.status,
    metadata: metadata ?? this.metadata,
  );
}

class Conversation {
  final String id;
  final String title;
  final String preview;
  final DateTime timestamp;
  final ConversationStatus status;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    required this.status,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'preview': preview,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    title: json['title'] as String,
    preview: json['preview'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    status: ConversationStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ConversationStatus.pending,
    ),
    messages: (json['messages'] as List<dynamic>)
        .map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}

class QuickAction {
  final String id;
  final String label;
  final String? sublabel;
  final String icon;
  final String prompt;

  QuickAction({
    required this.id,
    required this.label,
    this.sublabel,
    required this.icon,
    required this.prompt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'sublabel': sublabel,
    'icon': icon,
    'prompt': prompt,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    id: json['id'] as String,
    label: json['label'] as String,
    sublabel: json['sublabel'] as String?,
    icon: json['icon'] as String,
    prompt: json['prompt'] as String,
  );
}
