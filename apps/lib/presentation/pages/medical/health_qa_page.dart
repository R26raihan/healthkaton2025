import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Health QA Page - Q&A Personal Kesehatan
class HealthQAPage extends StatelessWidget {
  static const String routeName = AppRoutes.healthQA;
  
  const HealthQAPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A Personal Kesehatan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.question_answer,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Q&A Personal Kesehatan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tanya jawab berdasarkan data pribadi user',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Ajukan pertanyaan tentang kesehatan Anda dan dapatkan jawaban yang disesuaikan dengan data medis pribadi Anda.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

