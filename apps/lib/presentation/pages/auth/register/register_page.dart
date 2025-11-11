import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/assets/assets.dart';
import 'package:apps/presentation/pages/auth/register/register_form.dart';

/// Register Page - Halaman untuk user registrasi
class RegisterPage extends StatelessWidget {
  static const String routeName = AppRoutes.register;
  
  const RegisterPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset(
                AppAssets.logoHealth,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Daftar Akun',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Buat akun baru untuk mulai',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Register Form
              const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}

