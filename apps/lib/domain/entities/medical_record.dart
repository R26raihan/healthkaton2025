/// Medical Record entity - Business object untuk rekam medis
class MedicalRecord {
  final String recordId;
  final int patientId;
  final DateTime visitDate;
  final String visitType; // outpatient, inpatient, emergency
  final String? diagnosisSummary;
  final String? notes;
  final String? doctorName;
  final String? facilityName;
  final DateTime createdAt;
  
  const MedicalRecord({
    required this.recordId,
    required this.patientId,
    required this.visitDate,
    required this.visitType,
    this.diagnosisSummary,
    this.notes,
    this.doctorName,
    this.facilityName,
    required this.createdAt,
  });
}

