import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/health_calculation.dart';
import 'package:apps/domain/entities/health_metric.dart';

/// Repository interface untuk Health Calculator
abstract class HealthCalculatorRepository {
  Future<Either<Failure, List<HealthCalculation>>> getCalculationHistory({
    String? calculationType,
    int? limit,
    int? offset,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> saveCalculation({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  });
  
  Future<Either<Failure, List<HealthMetric>>> getMetrics({
    String? metricType,
    int? limit,
    int? offset,
  });
}

