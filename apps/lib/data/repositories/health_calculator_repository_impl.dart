import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/health_calculator_remote_datasource.dart';
import 'package:apps/domain/entities/health_calculation.dart';
import 'package:apps/domain/entities/health_metric.dart';
import 'package:apps/domain/repositories/health_calculator_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari HealthCalculatorRepository
class HealthCalculatorRepositoryImpl implements HealthCalculatorRepository {
  final HealthCalculatorRemoteDataSource remoteDataSource;
  
  HealthCalculatorRepositoryImpl({
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<HealthCalculation>>> getCalculationHistory({
    String? calculationType,
    int? limit,
    int? offset,
  }) async {
    try {
      final calculations = await remoteDataSource.getCalculationHistory(
        calculationType: calculationType,
        limit: limit,
        offset: offset,
      );
      return Right(calculations);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> saveCalculation({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  }) async {
    try {
      final result = await remoteDataSource.saveCalculation(
        calculationType: calculationType,
        inputData: inputData,
        resultData: resultData,
      );
      return Right(result);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<HealthMetric>>> getMetrics({
    String? metricType,
    int? limit,
    int? offset,
  }) async {
    try {
      final metrics = await remoteDataSource.getMetrics(
        metricType: metricType,
        limit: limit,
        offset: offset,
      );
      return Right(metrics);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

