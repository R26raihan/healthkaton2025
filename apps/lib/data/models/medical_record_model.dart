import 'package:apps/domain/entities/medical_record.dart';

/// Medical Record Model untuk JSON serialization
class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.recordId,
    required super.patientId,
    required super.visitDate,
    required super.visitType,
    super.diagnosisSummary,
    super.notes,
    super.doctorName,
    super.facilityName,
    required super.createdAt,
  });
  
  /// Convert dari JSON (dari backend API)
  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      recordId: json['record_id']?.toString() ?? '',
      patientId: json['patient_id'] is int 
          ? json['patient_id'] 
          : int.tryParse(json['patient_id']?.toString() ?? '0') ?? 0,
      visitDate: DateTime.parse(json['visit_date']?.toString() ?? DateTime.now().toIso8601String()),
      visitType: json['visit_type']?.toString() ?? 'outpatient',
      diagnosisSummary: json['diagnosis_summary']?.toString(),
      notes: json['notes']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      facilityName: json['facility_name']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'patient_id': patientId,
      'visit_date': visitDate.toIso8601String(),
      'visit_type': visitType,
      'diagnosis_summary': diagnosisSummary,
      'notes': notes,
      'doctor_name': doctorName,
      'facility_name': facilityName,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Convert dari Entity
  factory MedicalRecordModel.fromEntity(MedicalRecord record) {
    return MedicalRecordModel(
      recordId: record.recordId,
      patientId: record.patientId,
      visitDate: record.visitDate,
      visitType: record.visitType,
      diagnosisSummary: record.diagnosisSummary,
      notes: record.notes,
      doctorName: record.doctorName,
      facilityName: record.facilityName,
      createdAt: record.createdAt,
    );
  }
}

