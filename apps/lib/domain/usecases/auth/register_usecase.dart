import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/user.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk register user baru
class RegisterUsecase {
  final AuthRepository repository;
  
  RegisterUsecase(this.repository);
  
  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      ktpNumber: ktpNumber,
      kkNumber: kkNumber,
    );
  }
}

