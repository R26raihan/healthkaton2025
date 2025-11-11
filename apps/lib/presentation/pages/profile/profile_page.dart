import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/presentation/providers/auth_provider.dart';

/// Profile Page - Halaman untuk pengaturan aplikasi
class ProfilePage extends StatelessWidget {
  static const String routeName = '/profile';
  
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Profile Picture
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: authProvider.user?.profileImage != null && 
                                 authProvider.user!.profileImage!.isNotEmpty
                              ? Image.network(
                                  authProvider.user!.profileImage!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildAvatarInitial(authProvider.user);
                                  },
                                )
                              : _buildAvatarInitial(authProvider.user),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? '-',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Settings Section
                Text(
                  'Pengaturan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.editProfile);
                  },
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.notifications);
                  },
                ),
                _SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Keamanan',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.security);
                  },
                ),
                _SettingsItem(
                  icon: Icons.language,
                  title: 'Bahasa',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.language);
                  },
                ),
                _SettingsItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.help);
                  },
                ),
                _SettingsItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.about);
                  },
                ),
                const SizedBox(height: 24),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Apakah Anda yakin ingin logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true && context.mounted) {
                        authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAvatarInitial(user) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Center(
        child: Text(
          user?.name != null && user!.name.isNotEmpty
              ? user.name.substring(0, 1).toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

