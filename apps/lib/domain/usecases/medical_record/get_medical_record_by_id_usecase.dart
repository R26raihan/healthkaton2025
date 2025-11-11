import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:apps/domain/repositories/medical_record_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk get medical record by ID
class GetMedicalRecordByIdUsecase {
  final MedicalRecordRepository repository;
  
  GetMedicalRecordByIdUsecase(this.repository);
  
  Future<Either<Failure, MedicalRecordFull>> call(String recordId) {
    return repository.getMedicalRecordById(recordId);
  }
}

