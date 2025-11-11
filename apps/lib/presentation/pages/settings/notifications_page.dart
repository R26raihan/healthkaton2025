import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Notifications Page - Halaman pengaturan notifikasi
class NotificationsPage extends StatefulWidget {
  static const String routeName = '/notifications';
  
  const NotificationsPage({super.key});
  
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _appointmentReminders = true;
  bool _medicationReminders = true;
  bool _healthUpdates = true;
  bool _newsUpdates = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Notifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _NotificationSwitch(
              title: 'Push Notifikasi',
              subtitle: 'Terima notifikasi langsung di aplikasi',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            _NotificationSwitch(
              title: 'Email Notifikasi',
              subtitle: 'Terima notifikasi melalui email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            _NotificationSwitch(
              title: 'SMS Notifikasi',
              subtitle: 'Terima notifikasi melalui SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Kategori Notifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _NotificationSwitch(
              title: 'Pengingat Janji Temu',
              subtitle: 'Notifikasi untuk janji temu dengan dokter',
              value: _appointmentReminders,
              onChanged: (value) {
                setState(() {
                  _appointmentReminders = value;
                });
              },
            ),
            _NotificationSwitch(
              title: 'Pengingat Obat',
              subtitle: 'Notifikasi untuk waktu minum obat',
              value: _medicationReminders,
              onChanged: (value) {
                setState(() {
                  _medicationReminders = value;
                });
              },
            ),
            _NotificationSwitch(
              title: 'Update Kesehatan',
              subtitle: 'Notifikasi tentang update kesehatan Anda',
              value: _healthUpdates,
              onChanged: (value) {
                setState(() {
                  _healthUpdates = value;
                });
              },
            ),
            _NotificationSwitch(
              title: 'Berita Kesehatan',
              subtitle: 'Notifikasi tentang berita kesehatan terbaru',
              value: _newsUpdates,
              onChanged: (value) {
                setState(() {
                  _newsUpdates = value;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan notifikasi berhasil disimpan'),
                      backgroundColor: AppTheme.buttonGreen,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.buttonGreen.withValues(alpha: 0.5),
        activeThumbColor: AppTheme.buttonGreen,
      ),
    );
  }
}

