import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Doctor Questions Page - Pertanyaan untuk Dokter
class DoctorQuestionsPage extends StatelessWidget {
  static const String routeName = AppRoutes.doctorQuestions;
  
  const DoctorQuestionsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertanyaan untuk Dokter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 80,
              color: AppTheme.accentYellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Pertanyaan untuk Dokter',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'List pertanyaan rekomendasi saat konsultasi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Dapatkan daftar pertanyaan yang direkomendasikan untuk ditanyakan saat konsultasi dengan dokter berdasarkan kondisi kesehatan Anda.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

