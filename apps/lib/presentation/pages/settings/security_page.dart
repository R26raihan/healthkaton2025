import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Security Page - Halaman pengaturan keamanan
class SecurityPage extends StatelessWidget {
  static const String routeName = '/security';
  
  const SecurityPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keamanan Akun',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SecurityItem(
              icon: Icons.lock_outline,
              title: 'Ubah Kata Sandi',
              subtitle: 'Perbarui kata sandi Anda untuk keamanan lebih baik',
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            _SecurityItem(
              icon: Icons.fingerprint,
              title: 'Autentikasi Biometrik',
              subtitle: 'Gunakan sidik jari atau face ID untuk login',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur autentikasi biometrik akan segera hadir')),
                );
              },
            ),
            _SecurityItem(
              icon: Icons.shield_outlined,
              title: 'Verifikasi 2 Langkah',
              subtitle: 'Tingkatkan keamanan dengan verifikasi dua langkah',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur verifikasi 2 langkah akan segera hadir')),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Sesi Aktif',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_android, color: AppTheme.primaryGreen),
                title: const Text('Perangkat Ini'),
                subtitle: const Text('iPhone 14 Pro • Aktif sekarang'),
                trailing: Icon(Icons.check_circle, color: AppTheme.buttonGreen),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tindakan Lanjutan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SecurityItem(
              icon: Icons.logout,
              title: 'Keluar dari Semua Perangkat',
              subtitle: 'Keluar dari semua perangkat yang terhubung',
              onTap: () {
                _showLogoutAllDevicesDialog(context);
              },
              iconColor: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Kata Sandi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Kata Sandi Lama',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kata sandi baru tidak cocok')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kata sandi berhasil diubah'),
                  backgroundColor: AppTheme.buttonGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutAllDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Semua Perangkat'),
        content: const Text(
          'Anda akan logout dari semua perangkat yang terhubung. '
          'Anda perlu login kembali di semua perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil logout dari semua perangkat'),
                  backgroundColor: AppTheme.buttonGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  
  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

