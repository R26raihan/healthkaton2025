import 'package:dartz/dartz.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/allergy.dart';

/// Repository interface untuk Allergy
abstract class AllergyRepository {
  Future<Either<Failure, List<Allergy>>> getMyAllergies();
}

