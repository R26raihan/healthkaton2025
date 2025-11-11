import 'package:apps/domain/entities/health_metric.dart';

/// Health Metric Model
class HealthMetricModel extends HealthMetric {
  const HealthMetricModel({
    required super.metricId,
    required super.userId,
    required super.metricType,
    required super.metricValue,
    required super.unit,
    required super.recordedAt,
    super.notes,
  });

  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricModel(
      metricId: json['metric_id'] as int,
      userId: json['user_id'] as int,
      metricType: json['metric_type'] as String,
      metricValue: (json['metric_value'] as num).toDouble(),
      unit: json['unit'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric_id': metricId,
      'user_id': userId,
      'metric_type': metricType,
      'metric_value': metricValue,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

