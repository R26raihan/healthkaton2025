import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/prescription.dart';
import 'package:apps/domain/repositories/prescription_repository.dart';

class GetMyMedicationsUsecase {
  final PrescriptionRepository repository;

  GetMyMedicationsUsecase(this.repository);

  Future<Either<Failure, List<Prescription>>> call() async {
    return await repository.getMyMedications();
  }
}

