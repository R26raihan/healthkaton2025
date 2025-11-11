import 'package:apps/domain/entities/prescription.dart';

/// Prescription Model untuk JSON serialization
class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.prescriptionId,
    required super.recordId,
    required super.drugName,
    super.drugCode,
    super.dosage,
    super.frequency,
    super.durationDays,
    super.notes,
    required super.createdAt,
  });
  
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      prescriptionId: json['prescription_id']?.toString() ?? '',
      recordId: json['record_id']?.toString() ?? '',
      drugName: json['drug_name']?.toString() ?? '',
      drugCode: json['drug_code']?.toString(),
      dosage: json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      durationDays: json['duration_days'] is int 
          ? json['duration_days'] 
          : int.tryParse(json['duration_days']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'record_id': recordId,
      'drug_name': drugName,
      'drug_code': drugCode,
      'dosage': dosage,
      'frequency': frequency,
      'duration_days': durationDays,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

