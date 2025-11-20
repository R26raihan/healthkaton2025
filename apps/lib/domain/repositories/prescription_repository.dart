import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<Either<Failure, List<Prescription>>> getMyMedications();
}

