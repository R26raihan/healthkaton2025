import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/medical_record_remote_datasource.dart';
import 'package:apps/domain/entities/medical_record.dart';
import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:apps/domain/repositories/medical_record_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari MedicalRecordRepository
class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDataSource remoteDataSource;
  
  MedicalRecordRepositoryImpl({
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<MedicalRecord>>> getMyRecords({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final records = await remoteDataSource.getMyRecords(
        skip: skip,
        limit: limit,
      );
      return Right(records);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, MedicalRecordFull>> getMedicalRecordById(String recordId) async {
    try {
      final record = await remoteDataSource.getMedicalRecordById(recordId);
      return Right(record);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

