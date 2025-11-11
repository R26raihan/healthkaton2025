import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/health_calculation.dart';
import 'package:apps/domain/repositories/health_calculator_repository.dart';

/// Use case untuk mendapatkan calculation history
class GetCalculationHistoryUseCase {
  final HealthCalculatorRepository repository;
  
  GetCalculationHistoryUseCase(this.repository);
  
  Future<Either<Failure, List<HealthCalculation>>> call({
    String? calculationType,
    int? limit,
    int? offset,
  }) async {
    return await repository.getCalculationHistory(
      calculationType: calculationType,
      limit: limit,
      offset: offset,
    );
  }
}

