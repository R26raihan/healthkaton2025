import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk check apakah user sudah login
class CheckAuthUsecase {
  final AuthRepository repository;
  
  CheckAuthUsecase(this.repository);
  
  Future<Either<Failure, bool>> call() {
    return repository.isLoggedIn();
  }
}

