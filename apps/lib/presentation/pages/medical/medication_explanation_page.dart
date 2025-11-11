import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Medication Explanation Page - Penjelasan Obat
class MedicationExplanationPage extends StatelessWidget {
  static const String routeName = AppRoutes.medicationExplanation;
  
  const MedicationExplanationPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjelasan Obat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 80,
              color: AppTheme.accentYellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Penjelasan Obat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Penjelasan obat yang pernah diterima pasien',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Lihat penjelasan lengkap tentang obat-obatan yang pernah Anda terima, termasuk dosis, efek samping, dan cara penggunaan.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

