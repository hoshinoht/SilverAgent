enum TaskStatus { pending, inProgress, completed, failed }

enum ServiceType { transport, food, mart, health, finance, delivery, general }

class ExecutionStep {
  final String id;
  final String label;
  TaskStatus status;
  DateTime? timestamp;
  String? details;

  ExecutionStep({
    required this.id,
    required this.label,
    required this.status,
    this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'status': status.name,
      'timestamp': timestamp?.toIso8601String(),
      'details': details,
    };
  }

  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    return ExecutionStep(
      id: json['id'] as String,
      label: json['label'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      details: json['details'] as String?,
    );
  }

  ExecutionStep copyWith({
    String? id,
    String? label,
    TaskStatus? status,
    DateTime? timestamp,
    String? details,
  }) {
    return ExecutionStep(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  TaskStatus status;
  final ServiceType serviceType;
  final DateTime timestamp;
  final String? mcpAgentName;
  final String? eta;
  final String? price;
  List<ExecutionStep> executionSteps;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.serviceType,
    required this.timestamp,
    this.mcpAgentName,
    this.eta,
    this.price,
    List<ExecutionStep>? executionSteps,
  }) : executionSteps = executionSteps ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'serviceType': serviceType.name,
      'timestamp': timestamp.toIso8601String(),
      'mcpAgentName': mcpAgentName,
      'eta': eta,
      'price': price,
      'executionSteps': executionSteps.map((step) => step.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.general,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      mcpAgentName: json['mcpAgentName'] as String?,
      eta: json['eta'] as String?,
      price: json['price'] as String?,
      executionSteps:
          (json['executionSteps'] as List?)
              ?.map(
                (step) => ExecutionStep.fromJson(step as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    ServiceType? serviceType,
    DateTime? timestamp,
    String? mcpAgentName,
    String? eta,
    String? price,
    List<ExecutionStep>? executionSteps,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      timestamp: timestamp ?? this.timestamp,
      mcpAgentName: mcpAgentName ?? this.mcpAgentName,
      eta: eta ?? this.eta,
      price: price ?? this.price,
      executionSteps: executionSteps ?? this.executionSteps,
    );
  }
}

extension ServiceTypeExtension on ServiceType {
  String get displayName {
    switch (this) {
      case ServiceType.transport:
        return 'Transport';
      case ServiceType.food:
        return 'Food';
      case ServiceType.mart:
        return 'Mart';
      case ServiceType.health:
        return 'Health';
      case ServiceType.finance:
        return 'Finance';
      case ServiceType.delivery:
        return 'Express';
      case ServiceType.general:
        return 'General';
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'Running';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.failed:
        return 'Failed';
    }
  }
}
