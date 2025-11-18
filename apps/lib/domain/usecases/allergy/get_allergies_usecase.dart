import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/allergy.dart';
import 'package:apps/domain/repositories/allergy_repository.dart';

/// Use case untuk mendapatkan daftar alergi user
class GetAllergiesUsecase {
  final AllergyRepository repository;
  
  GetAllergiesUsecase(this.repository);
  
  Future<Either<Failure, List<Allergy>>> call() async {
    return await repository.getMyAllergies();
  }
}

