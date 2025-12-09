// Medical history models for SilverAgent app
// Simulates data from MCP healthcare servers

enum HealthcareAgentType { polyclinic, singhealth, nuhs }

class MedicalAppointment {
  final String date;
  final String hospital;
  final String department;
  final String doctor;
  final HealthcareAgentType agentType;

  MedicalAppointment({
    required this.date,
    required this.hospital,
    required this.department,
    required this.doctor,
    required this.agentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hospital': hospital,
      'department': department,
      'doctor': doctor,
      'agentType': agentType.toString(),
    };
  }

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) {
    return MedicalAppointment(
      date: json['date'] as String,
      hospital: json['hospital'] as String,
      department: json['department'] as String,
      doctor: json['doctor'] as String,
      agentType: HealthcareAgentType.values.firstWhere(
        (e) => e.toString() == json['agentType'],
        orElse: () => HealthcareAgentType.polyclinic,
      ),
    );
  }
}

class MedicalHistory {
  final String patientId;
  final String name;
  final String preferredHospital;
  final HealthcareAgentType preferredAgentType;
  final List<MedicalAppointment> recentAppointments;

  MedicalHistory({
    required this.patientId,
    required this.name,
    required this.preferredHospital,
    required this.preferredAgentType,
    required this.recentAppointments,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'name': name,
      'preferredHospital': preferredHospital,
      'preferredAgentType': preferredAgentType.toString(),
      'recentAppointments': recentAppointments.map((a) => a.toJson()).toList(),
    };
  }

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      preferredHospital: json['preferredHospital'] as String,
      preferredAgentType: HealthcareAgentType.values.firstWhere(
        (e) => e.toString() == json['preferredAgentType'],
        orElse: () => HealthcareAgentType.polyclinic,
      ),
      recentAppointments: (json['recentAppointments'] as List<dynamic>)
          .map((a) => MedicalAppointment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HospitalRecommendation {
  final HealthcareAgentType agentType;
  final String hospital;
  final String reason;

  HospitalRecommendation({
    required this.agentType,
    required this.hospital,
    required this.reason,
  });
}
