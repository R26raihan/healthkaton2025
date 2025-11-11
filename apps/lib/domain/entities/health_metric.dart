import 'package:equatable/equatable.dart';

/// Health Metric Entity
class HealthMetric extends Equatable {
  final int metricId;
  final int userId;
  final String metricType;
  final double metricValue;
  final String unit;
  final DateTime recordedAt;
  final String? notes;

  const HealthMetric({
    required this.metricId,
    required this.userId,
    required this.metricType,
    required this.metricValue,
    required this.unit,
    required this.recordedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        metricId,
        userId,
        metricType,
        metricValue,
        unit,
        recordedAt,
        notes,
      ];
}

