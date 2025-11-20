import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/prescription_remote_datasource.dart';
import 'package:apps/domain/entities/prescription.dart';
import 'package:apps/domain/repositories/prescription_repository.dart';
import 'package:dartz/dartz.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource remoteDataSource;

  PrescriptionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Prescription>>> getMyMedications() async {
    try {
      final prescriptions = await remoteDataSource.getMyMedications();
      return Right(prescriptions);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

