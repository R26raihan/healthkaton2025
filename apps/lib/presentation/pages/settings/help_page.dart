import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Help Page - Halaman bantuan dan FAQ
class HelpPage extends StatelessWidget {
  static const String routeName = '/help';
  
  const HelpPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertanyaan Umum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FAQItem(
              question: 'Bagaimana cara menggunakan aplikasi Healthkon BPJS?',
              answer: 'Aplikasi Healthkon BPJS menyediakan berbagai layanan kesehatan. '
                  'Anda dapat mengakses menu layanan dari dashboard untuk menggunakan fitur-fitur yang tersedia.',
            ),
            _FAQItem(
              question: 'Apakah aplikasi ini terhubung dengan sistem BPJS?',
              answer: 'Aplikasi ini sedang dalam pengembangan untuk terintegrasi dengan sistem BPJS. '
                  'Fitur integrasi akan tersedia dalam versi mendatang.',
            ),
            _FAQItem(
              question: 'Bagaimana cara mengubah profil saya?',
              answer: 'Anda dapat mengubah profil dengan membuka menu Profile dan memilih Edit Profil. '
                  'Di sana Anda dapat memperbarui informasi pribadi Anda.',
            ),
            _FAQItem(
              question: 'Bagaimana cara reset kata sandi?',
              answer: 'Untuk reset kata sandi, silakan buka menu Profile > Keamanan > Ubah Kata Sandi. '
                  'Anda perlu memasukkan kata sandi lama sebelum mengubah ke kata sandi baru.',
            ),
            _FAQItem(
              question: 'Apakah data saya aman?',
              answer: 'Kami sangat menjaga privasi dan keamanan data pengguna. '
                  'Semua data dienkripsi dan disimpan dengan aman sesuai dengan standar keamanan internasional.',
            ),
            const SizedBox(height: 24),
            Text(
              'Kontak Bantuan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ContactItem(
              icon: Icons.phone,
              title: 'Telepon',
              subtitle: '+62 800-1234-5678',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur panggilan akan segera hadir')),
                );
              },
            ),
            _ContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@healthkonbpjs.com',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur email akan segera hadir')),
                );
              },
            ),
            _ContactItem(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat langsung dengan tim support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur live chat akan segera hadir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  
  const _FAQItem({
    required this.question,
    required this.answer,
  });
  
  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

