import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';

/// About Page - Halaman tentang aplikasi
class AboutPage extends StatelessWidget {
  static const String routeName = '/about';
  
  const AboutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Healthkon BPJS',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Healthkon BPJS adalah aplikasi kesehatan yang menyediakan berbagai layanan untuk membantu Anda mengelola kesehatan dengan lebih baik. '
                'Aplikasi ini dilengkapi dengan fitur-fitur canggih seperti AI untuk penjelasan diagnosis, pemantauan kesehatan pribadi, dan berbagai layanan kesehatan lainnya.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _AboutSection(
              title: 'Fitur Utama',
              items: [
                'Ringkasan Rekam Medis',
                'Penjelasan Diagnosis AI',
                'Insight Riwayat Medis',
                'Q&A Personal Kesehatan',
                'Nutrisi & Pantangan Personal',
                'BMI & Self Monitoring',
              ],
            ),
            const SizedBox(height: 24),
            _AboutSection(
              title: 'Informasi',
              items: [
                'Dikembangkan oleh Tim Healthkon',
                '© 2024 Healthkon BPJS',
                'Semua hak dilindungi',
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.facebook,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur media sosial akan segera hadir')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: Icons.alternate_email,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur media sosial akan segera hadir')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: Icons.link,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur media sosial akan segera hadir')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Kebijakan Privasi • Syarat & Ketentuan',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryGreen,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final List<String> items;
  
  const _AboutSection({
    required this.title,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppTheme.buttonGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _SocialButton({
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}

