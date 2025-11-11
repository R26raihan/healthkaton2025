import 'package:flutter/material.dart';
import 'package:apps/presentation/widgets/common/custom_button.dart';

/// Login Button - Button khusus untuk login
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  
  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Masuk',
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

