import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Language Page - Halaman pengaturan bahasa
class LanguagePage extends StatefulWidget {
  static const String routeName = '/language';
  
  const LanguagePage({super.key});
  
  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'Bahasa Indonesia';
  
  final List<Map<String, String>> _languages = [
    {
      'name': 'Bahasa Indonesia',
      'code': 'id',
      'flag': '🇮🇩',
    },
    {
      'name': 'English',
      'code': 'en',
      'flag': '🇺🇸',
    },
    {
      'name': 'Bahasa Jawa',
      'code': 'jv',
      'flag': '🇮🇩',
    },
    {
      'name': 'Bahasa Sunda',
      'code': 'su',
      'flag': '🇮🇩',
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahasa'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Bahasa',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih bahasa yang ingin Anda gunakan di aplikasi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ..._languages.map((language) => _LanguageItem(
              flag: language['flag']!,
              name: language['name']!,
              isSelected: _selectedLanguage == language['name'],
              onTap: () {
                setState(() {
                  _selectedLanguage = language['name']!;
                });
              },
            )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bahasa berhasil diubah ke $_selectedLanguage'),
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

class _LanguageItem extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _LanguageItem({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(
          flag,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.buttonGreen)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}

