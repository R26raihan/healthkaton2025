import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/utils/api_helper.dart';
import 'package:apps/core/di/injection_container.dart' as di;
import 'package:apps/data/datasources/local/auth_local_datasource.dart';
import 'package:apps/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apps/data/repositories/auth_repository_impl.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:apps/domain/usecases/auth/login_usecase.dart';
import 'package:apps/domain/usecases/auth/register_usecase.dart';
import 'package:apps/presentation/providers/auth_provider.dart';
import 'package:apps/presentation/providers/dashboard_provider.dart';
import 'package:apps/presentation/providers/news_provider.dart';
import 'package:apps/presentation/providers/activity_provider.dart';
import 'package:apps/presentation/providers/medical_record_provider.dart';
import 'package:apps/presentation/routes/app_router.dart';
import 'package:apps/domain/usecases/news/get_health_news_usecase.dart';
import 'package:apps/data/datasources/remote/news_remote_datasource.dart';
import 'package:apps/data/repositories/news_repository_impl.dart';
import 'package:apps/domain/usecases/medical_record/get_medical_records_usecase.dart';
import 'package:apps/domain/usecases/medical_record/get_medical_record_by_id_usecase.dart';
import 'package:apps/data/datasources/remote/medical_record_remote_datasource.dart';
import 'package:apps/data/repositories/medical_record_repository_impl.dart';
import 'package:apps/domain/usecases/rag_chat/chat_usecase.dart';
import 'package:apps/data/datasources/remote/rag_chat_remote_datasource.dart';
import 'package:apps/data/repositories/rag_chat_repository_impl.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';
import 'package:apps/data/datasources/remote/health_calculator_remote_datasource.dart';
import 'package:apps/data/repositories/health_calculator_repository_impl.dart';
import 'package:apps/domain/usecases/health_calculator/get_calculation_history_usecase.dart';
import 'package:apps/domain/usecases/health_calculator/save_calculation_usecase.dart';
import 'package:apps/domain/usecases/health_calculator/get_metrics_usecase.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';

import 'package:apps/core/services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize TTS Service
  await TtsService.initialize();
  
  // Debug: Print network info (hanya di debug mode)
  if (kDebugMode) {
    try {
      // Clear cache untuk memastikan fresh detection
      ApiHelper.clearCache();
      
      await ApiHelper.debugPrintInterfaces();
      final baseUrl = await ApiHelper.getBaseUrl();
      print('🔗 [MAIN] ✅ Final base URL: $baseUrl');
      
      // Test connection
      final isConnected = await ApiHelper.testConnection(baseUrl, timeout: const Duration(seconds: 5));
      if (isConnected) {
        print('✅ [MAIN] Connection test: SUCCESS');
      } else {
        print('❌ [MAIN] Connection test: FAILED');
        print('⚠️ [MAIN] Make sure backend is running at $baseUrl');
      }
    } catch (e) {
      print('⚠️ [MAIN] Error detecting IP: $e');
    }
  }
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) {
            final repository = AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(),
              localDataSource: AuthLocalDataSourceImpl(di.getIt()),
            );
            return AuthProvider(
              LoginUsecase(repository),
              registerUsecase: RegisterUsecase(repository),
            );
          },
        ),
        // Repository Provider untuk use case check auth
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSourceImpl(),
            localDataSource: AuthLocalDataSourceImpl(di.getIt()),
          ),
        ),
        // Dashboard Provider
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        // News Provider
        ChangeNotifierProvider(
          create: (_) => NewsProvider(
            GetHealthNewsUsecase(
              NewsRepositoryImpl(
                remoteDataSource: NewsRemoteDataSourceImpl(),
              ),
            ),
          )..loadHealthNews(),
        ),
        // Activity Provider
        ChangeNotifierProvider(
          create: (_) => ActivityProvider()..initializeSampleData(),
        ),
        // Medical Record Provider
        ChangeNotifierProvider(
          create: (_) {
            final repository = MedicalRecordRepositoryImpl(
              remoteDataSource: MedicalRecordRemoteDataSourceImpl(),
            );
            return MedicalRecordProvider(
              GetMedicalRecordsUsecase(repository),
              GetMedicalRecordByIdUsecase(repository),
            )..loadMedicalRecords();
          },
        ),
        // RAG Chat Provider
        ChangeNotifierProvider(
          create: (_) {
            final repository = RagChatRepositoryImpl(
              remoteDataSource: RagChatRemoteDataSourceImpl(),
            );
            return RagChatProvider(ChatUsecase(repository));
          },
        ),
        // Health Calculator Provider
        ChangeNotifierProvider(
          create: (_) {
            final repository = HealthCalculatorRepositoryImpl(
              remoteDataSource: HealthCalculatorRemoteDataSourceImpl(),
            );
            return HealthCalculatorProvider(
              GetCalculationHistoryUseCase(repository),
              SaveCalculationUseCase(repository),
              GetMetricsUseCase(repository),
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Healthkon BPJS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
