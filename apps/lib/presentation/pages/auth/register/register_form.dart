import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/utils/validators.dart';
import 'package:apps/presentation/providers/auth_provider.dart';
import 'package:apps/presentation/widgets/common/custom_text_field.dart';
import 'package:apps/presentation/widgets/common/custom_button.dart';

/// Register Form - Form untuk registrasi user baru
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ktpController = TextEditingController();
  final _kkController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _nameController.dispose();
    _ktpController.dispose();
    _kkController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Validasi password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        ktpNumber: _ktpController.text.trim(),
        kkNumber: _kkController.text.trim(),
      );
      
      if (!mounted) return;
      
      if (success) {
        // Navigate to dashboard setelah register berhasil
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registrasi gagal'),
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
              // Name Field
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama harus diisi';
                  }
                  return null;
                },
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              // KTP Field
              CustomTextField(
                label: 'No KTP (e-KTP)',
                hint: 'Masukkan nomor KTP Anda',
                controller: _ktpController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'No KTP harus diisi';
                  }
                  if (value.trim().length != 16) {
                    return 'No KTP harus 16 digit';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'No KTP harus berupa angka';
                  }
                  return null;
                },
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              // KK Field
              CustomTextField(
                label: 'No KK (Kartu Keluarga)',
                hint: 'Masukkan nomor KK Anda',
                controller: _kkController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'No KK harus diisi';
                  }
                  if (value.trim().length != 16) {
                    return 'No KK harus 16 digit';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'No KK harus berupa angka';
                  }
                  return null;
                },
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              // Phone Field
              CustomTextField(
                label: 'Nomor HP Aktif',
                hint: 'Masukkan nomor HP aktif Anda',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor HP harus diisi';
                  }
                  if (value.trim().length < 10 || value.trim().length > 13) {
                    return 'Nomor HP harus 10-13 digit';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Nomor HP harus berupa angka';
                  }
                  return null;
                },
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              // Email Field
              CustomTextField(
                label: 'Email Aktif',
                hint: 'Masukkan email aktif Anda',
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
              const SizedBox(height: 20),
              // Confirm Password Field
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password Anda',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password harus diisi';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
                enabled: !authProvider.isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Register Button
              CustomButton(
                text: 'Daftar',
                onPressed: authProvider.isLoading ? null : _handleRegister,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              // Link to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                          },
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

