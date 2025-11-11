import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/assets/assets.dart';
import 'package:apps/presentation/pages/auth/login/login_form.dart';

/// Login Page - Halaman untuk user login
class LoginPage extends StatelessWidget {
  static const String routeName = AppRoutes.login;
  
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo
              Image.asset(
                AppAssets.logoHealth,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Selamat Datang',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun Anda',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Login Form
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

