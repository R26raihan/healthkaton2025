import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/allergy_remote_datasource.dart';
import 'package:apps/domain/entities/allergy.dart';
import 'package:apps/domain/repositories/allergy_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari AllergyRepository
class AllergyRepositoryImpl implements AllergyRepository {
  final AllergyRemoteDataSource remoteDataSource;
  
  AllergyRepositoryImpl({
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<Allergy>>> getMyAllergies() async {
    try {
      final allergies = await remoteDataSource.getMyAllergies();
      return Right(allergies);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

