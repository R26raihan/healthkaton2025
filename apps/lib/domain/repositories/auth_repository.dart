import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

/// Interface untuk Auth Repository
/// Domain layer tidak tahu tentang implementasi, hanya kontrak
abstract class AuthRepository {
  /// Login dengan email dan password
  Future<Either<Failure, User>> login(String email, String password);
  
  /// Register user baru
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  });
  
  /// Logout user
  Future<Either<Failure, void>> logout();
  
  /// Check apakah user sudah login
  Future<Either<Failure, bool>> isLoggedIn();
  
  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();
}

