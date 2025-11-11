import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/health_metric.dart';
import 'package:apps/domain/repositories/health_calculator_repository.dart';

/// Use case untuk mendapatkan health metrics
class GetMetricsUseCase {
  final HealthCalculatorRepository repository;
  
  GetMetricsUseCase(this.repository);
  
  Future<Either<Failure, List<HealthMetric>>> call({
    String? metricType,
    int? limit,
    int? offset,
  }) async {
    return await repository.getMetrics(
      metricType: metricType,
      limit: limit,
      offset: offset,
    );
  }
}

