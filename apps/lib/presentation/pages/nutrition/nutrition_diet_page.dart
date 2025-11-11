import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Nutrition Diet Page - Nutrisi & Pantangan Personal
class NutritionDietPage extends StatelessWidget {
  static const String routeName = AppRoutes.nutritionDiet;
  
  const NutritionDietPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrisi & Pantangan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: AppTheme.buttonGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Nutrisi & Pantangan Personal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rekomendasi diet sesuai diagnosa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Dapatkan rekomendasi nutrisi dan daftar pantangan makanan yang disesuaikan dengan kondisi kesehatan Anda.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

