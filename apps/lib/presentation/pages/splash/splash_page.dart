import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/assets/assets.dart';
import 'package:apps/domain/repositories/auth_repository.dart';
import 'package:apps/domain/usecases/auth/check_auth_usecase.dart';

/// Splash Screen - Halaman pertama yang muncul saat app dibuka
class SplashPage extends StatefulWidget {
  static const String routeName = AppRoutes.splash;
  
  const SplashPage({super.key});
  
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _navigateToNextPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToNextPage() async {
    // Delay untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check apakah user sudah login
    final authRepository = context.read<AuthRepository>();
    final checkAuthUsecase = CheckAuthUsecase(authRepository);
    
    final result = await checkAuthUsecase();
    
    if (!mounted) return;
    
    result.fold(
      (failure) {
        // Jika error, redirect ke login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
      (isLoggedIn) {
        if (isLoggedIn) {
          // Jika sudah login, redirect ke dashboard
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          // Jika belum login, redirect ke login
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    AppAssets.logoHealth,
                    width: 250,
                    height: 250,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

