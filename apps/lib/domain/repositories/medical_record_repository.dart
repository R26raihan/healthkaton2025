import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/medical_record.dart';
import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:dartz/dartz.dart';

/// Interface untuk Medical Record Repository
/// Domain layer tidak tahu tentang implementasi, hanya kontrak
abstract class MedicalRecordRepository {
  /// Get medical records untuk current user
  Future<Either<Failure, List<MedicalRecord>>> getMyRecords({
    int skip = 0,
    int limit = 100,
  });
  
  /// Get medical record by ID dengan semua data terkait
  Future<Either<Failure, MedicalRecordFull>> getMedicalRecordById(String recordId);
}

