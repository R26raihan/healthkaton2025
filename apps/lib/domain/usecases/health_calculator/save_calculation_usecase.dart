import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/repositories/health_calculator_repository.dart';

/// Use case untuk menyimpan calculation
class SaveCalculationUseCase {
  final HealthCalculatorRepository repository;
  
  SaveCalculationUseCase(this.repository);
  
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  }) async {
    return await repository.saveCalculation(
      calculationType: calculationType,
      inputData: inputData,
      resultData: resultData,
    );
  }
}

