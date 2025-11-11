import 'package:apps/domain/entities/health_calculation.dart';

/// Health Calculation Model
class HealthCalculationModel extends HealthCalculation {
  const HealthCalculationModel({
    required super.calculationId,
    required super.userId,
    required super.calculationType,
    required super.result,
    required super.calculatedAt,
  });

  factory HealthCalculationModel.fromJson(Map<String, dynamic> json) {
    return HealthCalculationModel(
      calculationId: json['calculation_id'] as int,
      userId: json['user_id'] as int,
      calculationType: json['calculation_type'] as String,
      result: json['result'] as Map<String, dynamic>,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculation_id': calculationId,
      'user_id': userId,
      'calculation_type': calculationType,
      'result': result,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}

