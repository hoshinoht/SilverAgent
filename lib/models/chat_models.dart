// Chat models for SilverAgent app

enum AgentType { general, polyclinic, singhealth, nuhs }

enum MessageStatus { pending, success, error, retrying }

enum ConversationStatus { active, completed, pending, error }

class AppointmentDetails {
  final String hospital;
  final String department;
  final String date;
  final String time;
  final String referenceNumber;

  AppointmentDetails({
    required this.hospital,
    required this.department,
    required this.date,
    required this.time,
    required this.referenceNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospital': hospital,
      'department': department,
      'date': date,
      'time': time,
      'referenceNumber': referenceNumber,
    };
  }

  factory AppointmentDetails.fromJson(Map<String, dynamic> json) {
    return AppointmentDetails(
      hospital: json['hospital'] as String,
      department: json['department'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      referenceNumber: json['referenceNumber'] as String,
    );
  }
}

class MessageMetadata {
  final AppointmentDetails? appointmentDetails;
  final bool? familyNotified;
  final int? retryCount;
  final int? maxRetries;
  final String? errorType;

  MessageMetadata({
    this.appointmentDetails,
    this.familyNotified,
    this.retryCount,
    this.maxRetries,
    this.errorType,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentDetails': appointmentDetails?.toJson(),
      'familyNotified': familyNotified,
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'errorType': errorType,
    };
  }

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      appointmentDetails: json['appointmentDetails'] != null
          ? AppointmentDetails.fromJson(json['appointmentDetails'])
          : null,
      familyNotified: json['familyNotified'] as bool?,
      retryCount: json['retryCount'] as int?,
      maxRetries: json['maxRetries'] as int?,
      errorType: json['errorType'] as String?,
    );
  }
}

class Message {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final bool isTyping;
  final AgentType? agentType;
  final MessageStatus? status;
  final MessageMetadata? metadata;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isTyping = false,
    this.agentType,
    this.status,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
      'agentType': agentType?.toString(),
      'status': status?.toString(),
      'metadata': metadata?.toJson(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTyping: json['isTyping'] as bool? ?? false,
      agentType: json['agentType'] != null
          ? AgentType.values.firstWhere(
              (e) => e.toString() == json['agentType'],
              orElse: () => AgentType.general,
            )
          : null,
      status: json['status'] != null
          ? MessageStatus.values.firstWhere(
              (e) => e.toString() == json['status'],
              orElse: () => MessageStatus.pending,
            )
          : null,
      metadata: json['metadata'] != null
          ? MessageMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final String preview;
  final DateTime timestamp;
  final ConversationStatus status;
  final AgentType? agentType;
  final bool caregiverNotified;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    required this.status,
    this.agentType,
    this.caregiverNotified = false,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'agentType': agentType?.toString(),
      'caregiverNotified': caregiverNotified,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: ConversationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ConversationStatus.pending,
      ),
      agentType: json['agentType'] != null
          ? AgentType.values.firstWhere(
              (e) => e.toString() == json['agentType'],
              orElse: () => AgentType.general,
            )
          : null,
      caregiverNotified: json['caregiverNotified'] as bool? ?? false,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuickAction {
  final String id;
  final String label;
  final String? sublabel;
  final String icon;
  final String prompt;
  final AgentType agentType;

  QuickAction({
    required this.id,
    required this.label,
    this.sublabel,
    required this.icon,
    required this.prompt,
    required this.agentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'sublabel': sublabel,
      'icon': icon,
      'prompt': prompt,
      'agentType': agentType.toString(),
    };
  }

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] as String,
      label: json['label'] as String,
      sublabel: json['sublabel'] as String?,
      icon: json['icon'] as String,
      prompt: json['prompt'] as String,
      agentType: AgentType.values.firstWhere(
        (e) => e.toString() == json['agentType'],
        orElse: () => AgentType.general,
      ),
    );
  }
}
