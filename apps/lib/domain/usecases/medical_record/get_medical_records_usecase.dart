import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/medical_record.dart';
import 'package:apps/domain/repositories/medical_record_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk get medical records
class GetMedicalRecordsUsecase {
  final MedicalRecordRepository repository;
  
  GetMedicalRecordsUsecase(this.repository);
  
  Future<Either<Failure, List<MedicalRecord>>> call({
    int skip = 0,
    int limit = 100,
  }) {
    return repository.getMyRecords(skip: skip, limit: limit);
  }
}

