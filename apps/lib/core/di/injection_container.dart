import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apps/data/datasources/local/auth_local_datasource.dart';
import 'package:apps/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apps/data/repositories/auth_repository_impl.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:apps/domain/usecases/auth/login_usecase.dart';
import 'package:apps/domain/usecases/auth/register_usecase.dart';
import 'package:apps/domain/usecases/auth/check_auth_usecase.dart';
import 'package:apps/presentation/providers/auth_provider.dart';

/// Dependency Injection menggunakan GetIt
/// Untuk project ini, kita bisa juga menggunakan Provider saja
/// Tapi GetIt membuat dependency injection lebih clean
final getIt = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => LoginUsecase(getIt()));
  getIt.registerLazySingleton(() => RegisterUsecase(getIt()));
  getIt.registerLazySingleton(() => CheckAuthUsecase(getIt()));
  
  // Providers
  getIt.registerFactory(
    () => AuthProvider(getIt()),
  );
}

