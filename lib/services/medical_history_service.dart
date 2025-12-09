// Medical History Service - Simulates MCP server data retrieval
// In production, this would connect to actual healthcare system APIs

import 'dart:async';
import '../models/medical_history.dart';

class MedicalHistoryService {
  // Mock data simulating what we'd get from an MCP server
  static final MedicalHistory _mockMedicalHistory = MedicalHistory(
    patientId: "SG1234567A",
    name: "Ah Ma",
    preferredHospital: "Singapore General Hospital",
    preferredAgentType: HealthcareAgentType.singhealth,
    recentAppointments: [
      MedicalAppointment(
        date: "2024-11-15",
        hospital: "Singapore General Hospital",
        department: "Orthopaedic",
        doctor: "Dr. Tan Wei Ming",
        agentType: HealthcareAgentType.singhealth,
      ),
      MedicalAppointment(
        date: "2024-10-20",
        hospital: "Singapore General Hospital",
        department: "Cardiology",
        doctor: "Dr. Lee Siew Ling",
        agentType: HealthcareAgentType.singhealth,
      ),
      MedicalAppointment(
        date: "2024-09-05",
        hospital: "Bedok Polyclinic",
        department: "General Practice",
        doctor: "Dr. Ahmad",
        agentType: HealthcareAgentType.polyclinic,
      ),
    ],
  );

  /// Simulates fetching from MCP server
  static Future<MedicalHistory> fetchMedicalHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMedicalHistory;
  }

  /// Get the most frequently visited hospital system
  static HealthcareAgentType getPreferredAgent(MedicalHistory history) {
    final counts = <HealthcareAgentType, int>{
      HealthcareAgentType.polyclinic: 0,
      HealthcareAgentType.singhealth: 0,
      HealthcareAgentType.nuhs: 0,
    };

    for (var apt in history.recentAppointments) {
      counts[apt.agentType] = (counts[apt.agentType] ?? 0) + 1;
    }

    // Return the most visited, or fallback to preferredAgentType
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.value > 0
        ? sorted.first.key
        : history.preferredAgentType;
  }

  /// Get context string for the AI agent
  static String getMedicalContext(MedicalHistory history) {
    if (history.recentAppointments.isEmpty) {
      return "Welcome! I'll help you book your appointments.";
    }

    final recent = history.recentAppointments.first;
    return "Based on your medical history, you usually visit ${history.preferredHospital}. "
        "Your last appointment was at ${recent.department} with ${recent.doctor}.";
  }

  /// Get smart recommendation based on symptoms and history
  static HospitalRecommendation getSmartHospitalRecommendation(
    MedicalHistory history,
    List<String>? symptoms,
  ) {
    // If user has specialist history and symptoms suggest specialist need
    final specialistSymptoms = ['bone', 'heart', 'eye', 'skin', 'nerve'];
    final needsSpecialist =
        symptoms?.any(
          (s) =>
              specialistSymptoms.any((spec) => s.toLowerCase().contains(spec)),
        ) ??
        false;

    if (needsSpecialist) {
      // Route to their usual specialist hospital
      return HospitalRecommendation(
        agentType: history.preferredAgentType,
        hospital: history.preferredHospital,
        reason:
            "Since you've been seeing specialists at ${history.preferredHospital}, I'll book there.",
      );
    }

    // For general issues, recommend polyclinic first
    return HospitalRecommendation(
      agentType: HealthcareAgentType.polyclinic,
      hospital: "Bedok Polyclinic",
      reason: "For general check-ups, the polyclinic near your home is best.",
    );
  }
}
