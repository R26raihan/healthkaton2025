/// Prescription entity
class Prescription {
  final String prescriptionId;
  final String recordId;
  final String drugName;
  final String? drugCode;
  final String? dosage;
  final String? frequency;
  final int? durationDays;
  final String? notes;
  final DateTime createdAt;
  
  const Prescription({
    required this.prescriptionId,
    required this.recordId,
    required this.drugName,
    this.drugCode,
    this.dosage,
    this.frequency,
    this.durationDays,
    this.notes,
    required this.createdAt,
  });
}

