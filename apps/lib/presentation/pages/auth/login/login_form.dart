import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/utils/validators.dart';
import 'package:apps/presentation/providers/auth_provider.dart';
import 'package:apps/presentation/widgets/common/custom_text_field.dart';
import 'package:apps/presentation/pages/auth/login/login_button.dart';

/// Login Form - Form untuk input email dan password
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        // Navigate to dashboard setelah login berhasil
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              // Password Field
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: Validators.validatePassword,
                enabled: !authProvider.isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Login Button
              LoginButton(
                onPressed: _handleLogin,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              // Link to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.register);
                          },
                    child: const Text('Daftar'),
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              // Demo credentials info
              // Text(
              //   // 'Demo: admin@example.com / password123',
              //   // style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //   //   color: Colors.grey[600],
              //   // ),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        );
      },
    );
  }
}

