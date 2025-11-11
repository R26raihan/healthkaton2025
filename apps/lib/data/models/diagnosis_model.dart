import 'package:apps/domain/entities/diagnosis.dart';

/// Diagnosis Model untuk JSON serialization
class DiagnosisModel extends Diagnosis {
  const DiagnosisModel({
    required super.diagnosisId,
    required super.recordId,
    super.icdCode,
    required super.diagnosisName,
    required super.primaryFlag,
    required super.createdAt,
  });
  
  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      diagnosisId: json['diagnosis_id']?.toString() ?? '',
      recordId: json['record_id']?.toString() ?? '',
      icdCode: json['icd_code']?.toString(),
      diagnosisName: json['diagnosis_name']?.toString() ?? '',
      primaryFlag: json['primary_flag'] ?? false,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'diagnosis_id': diagnosisId,
      'record_id': recordId,
      'icd_code': icdCode,
      'diagnosis_name': diagnosisName,
      'primary_flag': primaryFlag,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

