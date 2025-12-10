// Chat Provider - State management for chat functionality
// Manages messages, conversations, and chat interactions

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../models/medical_history.dart';
import '../services/medical_history_service.dart';
import '../services/silver_agent_service.dart';

class ChatProvider with ChangeNotifier {
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  List<Message> _messages = [];
  bool _isLoading = false;
  AgentType? _activeAgent;
  bool _familyNotified = false;
  MedicalHistory? _medicalHistory;

  // Getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get activeConversationId => _activeConversationId;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  AgentType? get activeAgent => _activeAgent;
  bool get familyNotified => _familyNotified;
  MedicalHistory? get medicalHistory => _medicalHistory;
  bool get isNewConversation =>
      _messages.length <= 1 && _activeConversationId == null;

  // Quick actions - senior-friendly
  final List<QuickAction> quickActions = [
    QuickAction(
      id: '1',
      label: 'Book Appointment',
      sublabel: 'Smart routing',
      icon: 'smart',
      prompt: 'I need to book a doctor appointment',
      agentType: AgentType.general,
    ),
    QuickAction(
      id: '2',
      label: 'See My Doctor',
      sublabel: 'Usual hospital',
      icon: 'doctor',
      prompt: 'I want to see my regular doctor',
      agentType: AgentType.general,
    ),
    QuickAction(
      id: '3',
      label: 'Polyclinic',
      sublabel: 'General check-up',
      icon: 'polyclinic',
      prompt: 'I want to book a polyclinic appointment',
      agentType: AgentType.polyclinic,
    ),
    QuickAction(
      id: '4',
      label: 'Help Me',
      sublabel: 'Not sure what to do',
      icon: 'help',
      prompt: 'I need help, not sure where to go',
      agentType: AgentType.general,
    ),
  ];

  ChatProvider() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load medical history (simulates MCP server call)
    try {
      _medicalHistory = await MedicalHistoryService.fetchMedicalHistory();
      _messages = [_createWelcomeMessage(_medicalHistory)];

      // Load sample conversations
      _loadSampleConversations();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading medical history: $e');
      _messages = [_createWelcomeMessage(null)];
      notifyListeners();
    }
  }

  void _loadSampleConversations() {
    final now = DateTime.now();
    _conversations.addAll([
      Conversation(
        id: 'conv-1',
        title: 'SGH Orthopaedic Appointment',
        preview: 'Appointment booked for knee check-up',
        timestamp: now.subtract(const Duration(days: 2)),
        status: ConversationStatus.completed,
        agentType: AgentType.singhealth,
        caregiverNotified: true,
        messages: [
          Message(
            id: '1',
            content: 'My knee pain, need see bone doctor at SGH',
            role: 'user',
            timestamp: now.subtract(const Duration(days: 2)),
          ),
          Message(
            id: '2',
            content:
                "I understand! I'll help you book an Orthopaedic appointment at SGH. Let me check the available slots...",
            role: 'assistant',
            timestamp: now.subtract(const Duration(days: 2)),
            agentType: AgentType.singhealth,
          ),
        ],
      ),
      Conversation(
        id: 'conv-2',
        title: 'Polyclinic Check-up',
        preview: 'Regular health screening booked',
        timestamp: now.subtract(const Duration(days: 5)),
        status: ConversationStatus.completed,
        agentType: AgentType.polyclinic,
        caregiverNotified: true,
        messages: [
          Message(
            id: '1',
            content: 'I want to do my yearly checkup',
            role: 'user',
            timestamp: now.subtract(const Duration(days: 5)),
          ),
          Message(
            id: '2',
            content:
                "Great idea! Regular check-ups are important. Let me book a health screening at your nearest polyclinic.",
            role: 'assistant',
            timestamp: now.subtract(const Duration(days: 5)),
            agentType: AgentType.polyclinic,
          ),
        ],
      ),
    ]);
  }

  Message _createWelcomeMessage(MedicalHistory? medicalHistory) {
    String content;
    if (medicalHistory != null) {
      final context = MedicalHistoryService.getMedicalContext(medicalHistory);
      content =
          "Hello ${medicalHistory.name}! I'm SilverAgent, your healthcare helper. 😊\n\n"
          "$context\n\n"
          "Just tell me what you need - I'll route you to the right hospital automatically!";
    } else {
      content =
          "Hello! I'm SilverAgent, your healthcare helper. 😊\n\n"
          "I can help you book doctor appointments easily. Just tell me what you need!";
    }

    return Message(
      id: '1',
      content: content,
      role: 'assistant',
      timestamp: DateTime.now(),
      agentType: AgentType.general,
    );
  }

  void startNewConversation() {
    _activeConversationId = null;
    _messages = [_createWelcomeMessage(_medicalHistory)];
    _activeAgent = null;
    _familyNotified = false;
    notifyListeners();
  }

  void selectConversation(String id) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == id,
      orElse: () => _conversations.first,
    );

    _activeConversationId = id;
    _messages = List.from(conversation.messages);
    _activeAgent = conversation.agentType;
    _familyNotified = conversation.caregiverNotified;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      role: 'user',
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    // Detect intent from user input
    final intent = SilverAgentService.detectIntent(content);

    // Smart routing: use medical history to determine best agent
    AgentType agentType = intent.agentType;
    if (agentType == AgentType.general && _medicalHistory != null) {
      final symptoms = intent.entities['symptoms'] as List<String>?;
      final recommendation =
          MedicalHistoryService.getSmartHospitalRecommendation(
            _medicalHistory!,
            symptoms,
          );

      // Map HealthcareAgentType to AgentType
      switch (recommendation.agentType) {
        case HealthcareAgentType.singhealth:
          agentType = AgentType.singhealth;
          break;
        case HealthcareAgentType.nuhs:
          agentType = AgentType.nuhs;
          break;
        case HealthcareAgentType.polyclinic:
          agentType = AgentType.polyclinic;
          break;
      }

      if (!intent.entities.containsKey('hospital')) {
        intent.entities['hospital'] = recommendation.hospital;
      }
    }

    _activeAgent = agentType;

    // Create or update conversation
    if (_activeConversationId == null) {
      final newConv = Conversation(
        id: const Uuid().v4(),
        title: SilverAgentService.generateConversationTitle(content, intent),
        preview: content,
        timestamp: DateTime.now(),
        status: ConversationStatus.active,
        agentType: agentType,
        messages: List.from(_messages),
      );
      _conversations.insert(0, newConv);
      _activeConversationId = newConv.id;
    }

    // Add typing indicator
    final typingMessage = Message(
      id: 'typing',
      content: '',
      role: 'assistant',
      timestamp: DateTime.now(),
      isTyping: true,
      agentType: agentType,
    );
    _messages.add(typingMessage);
    notifyListeners();

    // Simulate AI response
    try {
      Message aiResponse;

      if (intent.intent == 'book_appointment' && intent.confidence > 0.6) {
        aiResponse = await SilverAgentService.simulateAgentResponse(intent);

        if (aiResponse.status == MessageStatus.success &&
            aiResponse.metadata?.familyNotified == true) {
          _familyNotified = true;
        }
      } else {
        aiResponse = Message(
          id: const Uuid().v4(),
          content: SilverAgentService.getContextualResponse(content, intent),
          role: 'assistant',
          timestamp: DateTime.now(),
          agentType: agentType,
        );
      }

      // Remove typing indicator and add actual response
      _messages.removeWhere((m) => m.id == 'typing');
      _messages.add(aiResponse);

      // Update conversation
      if (_activeConversationId != null) {
        final index = _conversations.indexWhere(
          (c) => c.id == _activeConversationId,
        );
        if (index != -1) {
          final updatedConv = Conversation(
            id: _conversations[index].id,
            title: _conversations[index].title,
            preview: aiResponse.content.substring(
              0,
              aiResponse.content.length > 50 ? 50 : aiResponse.content.length,
            ),
            timestamp: _conversations[index].timestamp,
            status: aiResponse.status == MessageStatus.error
                ? ConversationStatus.error
                : aiResponse.status == MessageStatus.success
                ? ConversationStatus.completed
                : ConversationStatus.active,
            agentType: _conversations[index].agentType,
            caregiverNotified:
                aiResponse.metadata?.familyNotified ??
                _conversations[index].caregiverNotified,
            messages: List.from(_messages),
          );
          _conversations[index] = updatedConv;
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      _messages.removeWhere((m) => m.id == 'typing');
      _messages.add(
        Message(
          id: const Uuid().v4(),
          content: 'Sorry, something went wrong. Please try again.',
          role: 'assistant',
          timestamp: DateTime.now(),
          agentType: agentType,
          status: MessageStatus.error,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
