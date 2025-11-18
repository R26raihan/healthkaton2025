import 'package:apps/domain/entities/allergy.dart';

/// Allergy Model untuk JSON serialization
class AllergyModel extends Allergy {
  const AllergyModel({
    required super.allergyId,
    required super.patientId,
    required super.allergyName,
    required super.severity,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });
  
  /// Convert dari JSON (dari backend API)
  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      allergyId: json['allergy_id']?.toString() ?? '',
      patientId: json['patient_id'] is int 
          ? json['patient_id'] 
          : int.tryParse(json['patient_id']?.toString() ?? '0') ?? 0,
      allergyName: json['allergy_name']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'moderate',
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'allergy_id': allergyId,
      'patient_id': patientId,
      'allergy_name': allergyName,
      'severity': severity,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Convert dari Entity
  factory AllergyModel.fromEntity(Allergy allergy) {
    return AllergyModel(
      allergyId: allergy.allergyId,
      patientId: allergy.patientId,
      allergyName: allergy.allergyName,
      severity: allergy.severity,
      notes: allergy.notes,
      createdAt: allergy.createdAt,
      updatedAt: allergy.updatedAt,
    );
  }
}

