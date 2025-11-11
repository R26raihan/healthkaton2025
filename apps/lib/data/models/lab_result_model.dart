import 'package:apps/domain/entities/lab_result.dart';

/// Lab Result Model untuk JSON serialization
class LabResultModel extends LabResult {
  const LabResultModel({
    required super.labId,
    required super.recordId,
    required super.testName,
    super.resultValue,
    super.resultUnit,
    super.normalRange,
    super.interpretation,
    super.attachmentUrl,
    required super.createdAt,
  });
  
  factory LabResultModel.fromJson(Map<String, dynamic> json) {
    return LabResultModel(
      labId: json['lab_id']?.toString() ?? '',
      recordId: json['record_id']?.toString() ?? '',
      testName: json['test_name']?.toString() ?? '',
      resultValue: json['result_value']?.toString(),
      resultUnit: json['result_unit']?.toString(),
      normalRange: json['normal_range']?.toString(),
      interpretation: json['interpretation']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'lab_id': labId,
      'record_id': recordId,
      'test_name': testName,
      'result_value': resultValue,
      'result_unit': resultUnit,
      'normal_range': normalRange,
      'interpretation': interpretation,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

