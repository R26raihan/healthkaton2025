import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Medical Insight Page - Insight Riwayat Medis dengan AI
class MedicalInsightPage extends StatelessWidget {
  static const String routeName = AppRoutes.medicalInsight;
  
  const MedicalInsightPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insight Riwayat Medis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 80,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'Insight Riwayat Medis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI temukan pola kesehatan user',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Fitur AI akan menganalisis riwayat medis Anda dan menemukan pola-pola kesehatan yang penting untuk diketahui.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

