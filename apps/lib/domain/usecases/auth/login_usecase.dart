import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/user.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk login
class LoginUsecase {
  final AuthRepository repository;
  
  LoginUsecase(this.repository);
  
  Future<Either<Failure, User>> call(String email, String password) {
    return repository.login(email, password);
  }
}

