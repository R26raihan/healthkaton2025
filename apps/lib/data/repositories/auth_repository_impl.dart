import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/local/auth_local_datasource.dart';
import 'package:apps/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apps/domain/entities/user.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Step 1: Login dan dapatkan token
      final loginResponse = await remoteDataSource.login(email, password);
      final accessToken = loginResponse['access_token'] as String;
      
      // Step 2: Save token ke secure storage terlebih dahulu
      await localDataSource.saveToken(accessToken);
      
      // Step 3: Get user info menggunakan token (endpoint /me)
      final userModel = await remoteDataSource.getCurrentUser(accessToken);
      
      // Step 4: Save user data ke local storage
      await localDataSource.saveUser(userModel);
      
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        ktpNumber: ktpNumber,
        kkNumber: kkNumber,
      );
      
      // Save token dan user ke local storage
      await localDataSource.saveToken('token_${userModel.id}');
      await localDataSource.saveUser(userModel);
      
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal logout: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure('Gagal cek status login: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Gagal mendapatkan user: ${e.toString()}'));
    }
  }
}

