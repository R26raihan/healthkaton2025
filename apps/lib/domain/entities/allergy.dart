/// Allergy entity - Business object untuk alergi pasien
class Allergy {
  final String allergyId;
  final int patientId;
  final String allergyName;
  final String severity; // low, moderate, high
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Allergy({
    required this.allergyId,
    required this.patientId,
    required this.allergyName,
    required this.severity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}

