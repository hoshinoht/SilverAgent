// SilverAgent Service - Intent detection and AI response logic
// Simulates AI-powered healthcare assistant capabilities

import 'dart:math';
import '../models/chat_models.dart';

class IntentDetectionResult {
  final String intent;
  final double confidence;
  final Map<String, dynamic> entities;
  final AgentType agentType;

  IntentDetectionResult({
    required this.intent,
    required this.confidence,
    required this.entities,
    required this.agentType,
  });
}

class SilverAgentService {
  /// Detect intent from user input
  static IntentDetectionResult detectIntent(String input) {
    final lowerInput = input.toLowerCase();
    final entities = <String, dynamic>{};
    var confidence = 0.5;
    var intent = 'unknown';
    var agentType = AgentType.general;

    // Check for booking intent
    if (lowerInput.contains('book') ||
        lowerInput.contains('appointment') ||
        lowerInput.contains('see doctor') ||
        lowerInput.contains('schedule')) {
      intent = 'book_appointment';
      confidence = 0.8;
    }

    // Extract hospital entities
    if (lowerInput.contains('sgh') ||
        lowerInput.contains('singapore general')) {
      entities['hospital'] = 'Singapore General Hospital';
      agentType = AgentType.singhealth;
      confidence += 0.1;
    } else if (lowerInput.contains('nuh') ||
        lowerInput.contains('national university')) {
      entities['hospital'] = 'National University Hospital';
      agentType = AgentType.nuhs;
      confidence += 0.1;
    } else if (lowerInput.contains('polyclinic')) {
      entities['hospital'] = 'Polyclinic';
      agentType = AgentType.polyclinic;
      confidence += 0.1;
    }

    // Extract specialty entities
    if (lowerInput.contains('bone') || lowerInput.contains('orthop')) {
      entities['speciality'] = 'orthopaedic';
      entities['symptoms'] = ['bone'];
    } else if (lowerInput.contains('heart') || lowerInput.contains('cardio')) {
      entities['speciality'] = 'cardiology';
      entities['symptoms'] = ['heart'];
    } else if (lowerInput.contains('eye') || lowerInput.contains('vision')) {
      entities['speciality'] = 'ophthalmology';
      entities['symptoms'] = ['eye'];
    } else if (lowerInput.contains('skin') || lowerInput.contains('dermat')) {
      entities['speciality'] = 'dermatology';
      entities['symptoms'] = ['skin'];
    } else if (lowerInput.contains('nerve') || lowerInput.contains('neuro')) {
      entities['speciality'] = 'neurology';
      entities['symptoms'] = ['nerve'];
    }

    // Extract symptoms
    final symptomsList = <String>[];
    if (lowerInput.contains('pain')) symptomsList.add('pain');
    if (lowerInput.contains('headache')) symptomsList.add('headache');
    if (lowerInput.contains('fever')) symptomsList.add('fever');
    if (lowerInput.contains('cough')) symptomsList.add('cough');
    if (symptomsList.isNotEmpty) {
      entities['symptoms'] = symptomsList;
    }

    return IntentDetectionResult(
      intent: intent,
      confidence: confidence.clamp(0.0, 1.0),
      entities: entities,
      agentType: agentType,
    );
  }

  /// Get agent name for display
  static String getAgentName(AgentType agentType) {
    switch (agentType) {
      case AgentType.singhealth:
        return 'SingHealth Portal';
      case AgentType.nuhs:
        return 'NUHS Portal';
      case AgentType.polyclinic:
        return 'Polyclinic Portal';
      case AgentType.general:
        return 'SilverAgent';
    }
  }

  /// Get senior-friendly error messages
  static String getSeniorFriendlyError(String errorType, int retryCount) {
    switch (errorType) {
      case 'portal_down':
        if (retryCount < 2) {
          return "The hospital system is busy right now. Let me try again for you... ⏳";
        } else {
          return "Sorry, the hospital system is not responding. 😔\n\n"
              "Don't worry! You can:\n"
              "• Try again in a few minutes\n"
              "• Call the hospital directly at 6321 4377\n"
              "• I can help you with another hospital";
        }
      case 'network':
        return "Your internet connection is weak. Please check your WiFi and try again. 📶";
      case 'timeout':
        return "This is taking longer than usual. Let me try again... ⏰";
      default:
        return "Something went wrong. Let me help you try a different way. 🔄";
    }
  }

  /// Generate senior-friendly confirmation message
  static String generateSeniorConfirmation(AppointmentDetails details) {
    return "✅ Great news! Your appointment is booked!\n\n"
        "📍 Hospital: ${details.hospital}\n"
        "🏥 Department: ${details.department}\n"
        "📅 Date: ${details.date}\n"
        "🕒 Time: ${details.time}\n"
        "🎫 Reference: ${details.referenceNumber}\n\n"
        "💚 Your family member has been notified!\n\n"
        "Please arrive 15 minutes early. Bring your NRIC and referral letter if you have one.";
  }

  /// Simulate agent response with appointment booking
  static Future<Message> simulateAgentResponse(
    IntentDetectionResult intent,
  ) async {
    // Simulate portal connection delay
    await Future.delayed(const Duration(seconds: 2));

    final agentType = intent.agentType;

    // Simulate potential errors (15% chance)
    final hasError = Random().nextDouble() < 0.15;

    if (hasError) {
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: getSeniorFriendlyError('portal_down', 0),
        role: 'assistant',
        timestamp: DateTime.now(),
        agentType: agentType,
        status: MessageStatus.retrying,
        metadata: MessageMetadata(
          retryCount: 1,
          maxRetries: 3,
          errorType: 'portal_down',
        ),
      );
    }

    // Simulate successful booking
    final appointmentDetails = AppointmentDetails(
      hospital: intent.entities['hospital'] ?? 'Singapore General Hospital',
      department: intent.entities['speciality'] ?? 'General Medicine',
      date: 'Monday, 15 January 2024',
      time: '10:30 AM',
      referenceNumber: 'SGH${Random().nextInt(900000) + 100000}',
    );

    final confirmationMessage = generateSeniorConfirmation(appointmentDetails);

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: confirmationMessage,
      role: 'assistant',
      timestamp: DateTime.now(),
      agentType: agentType,
      status: MessageStatus.success,
      metadata: MessageMetadata(
        appointmentDetails: appointmentDetails,
        familyNotified: true,
      ),
    );
  }

  /// Get contextual response for general queries
  static String getContextualResponse(
    String input,
    IntentDetectionResult intent,
  ) {
    final lowerInput = input.toLowerCase();

    if (intent.intent == 'book_appointment') {
      if (intent.entities.containsKey('hospital') &&
          intent.entities.containsKey('speciality')) {
        return "I understand you need to see a ${intent.entities['speciality']} doctor at ${intent.entities['hospital']}. "
            "Let me help you book that!\n\nI'm checking available appointment slots now...";
      }
      if (intent.entities.containsKey('hospital')) {
        return "I'll help you book at ${intent.entities['hospital']}. "
            "What kind of doctor do you need to see? For example: bone doctor, eye doctor, heart doctor?";
      }
      if (intent.entities.containsKey('speciality')) {
        return "I understand you need to see a ${intent.entities['speciality']} doctor. "
            "Which hospital would you like to go to?\n\n"
            "• SGH (Singapore General Hospital)\n"
            "• NUH (National University Hospital)\n"
            "• Polyclinic (near your home)";
      }
    }

    if (lowerInput.contains('help') || lowerInput.contains('not sure')) {
      return "No problem! I'm here to help you. 😊\n\n"
          "Let me ask you some simple questions:\n\n"
          "1. Are you feeling unwell? What part of your body has problems?\n"
          "2. Is this urgent (very painful) or can wait?\n"
          "3. Do you have a regular doctor you see?";
    }

    if (lowerInput.contains('pain') || lowerInput.contains('hurt')) {
      return "I'm sorry to hear you're in pain. 💚\n\n"
          "Can you tell me:\n"
          "• Where is the pain? (leg, arm, chest, stomach?)\n"
          "• How long have you had this pain?\n"
          "• Is it very painful or can wait?";
    }

    return "I understand you said: \"$input\"\n\n"
        "Can you tell me more? I can help you:\n\n"
        "• Book doctor appointments\n"
        "• Find the right hospital\n"
        "• Check your existing bookings\n\n"
        "Just tell me what you need!";
  }

  /// Generate conversation title from user input
  static String generateConversationTitle(
    String content,
    IntentDetectionResult intent,
  ) {
    if (intent.entities.containsKey('hospital')) {
      return '${intent.entities['hospital']} Appointment';
    }
    if (intent.entities.containsKey('speciality')) {
      final specialty = intent.entities['speciality'] as String;
      return '${specialty[0].toUpperCase()}${specialty.substring(1)} Visit';
    }
    final words = content.split(' ').take(4).join(' ');
    return words.length > 30 ? '${words.substring(0, 30)}...' : words;
  }
}
