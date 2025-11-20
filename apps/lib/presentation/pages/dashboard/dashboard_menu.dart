import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/activity_provider.dart';

/// Dashboard Menu - Menu items untuk layanan BPJS
class DashboardMenu extends StatelessWidget {
  final List<GlobalKey>? menuKeys;
  
  const DashboardMenu({
    super.key,
    this.menuKeys,
  });
  
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.isNotEmpty ? menuKeys![0] : null,
        title: 'Ringkasan Rekam Medis',
        icon: Bootstrap.file_medical,
        color: AppTheme.primaryGreen,
        onTap: () {
          Provider.of<ActivityProvider>(context, listen: false).logActivity(
            title: 'Melihat Ringkasan Rekam Medis',
            description: 'Anda membuka halaman Ringkasan Rekam Medis',
            iconName: 'file_medical',
          );
          Navigator.of(context).pushNamed(AppRoutes.medicalSummary);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 1 ? menuKeys![1] : null,
        title: 'Penjelasan Obat',
        icon: Bootstrap.capsule,
        color: AppTheme.accentYellow,
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.medicationExplanation);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 2 ? menuKeys![2] : null,
        title: 'Daftar Alergi',
        icon: Bootstrap.exclamation_triangle,
        color: Colors.orange,
        onTap: () {
          Provider.of<ActivityProvider>(context, listen: false).logActivity(
            title: 'Melihat Daftar Alergi',
            description: 'Anda membuka halaman Daftar Alergi',
            iconName: 'exclamation_triangle',
          );
          Navigator.of(context).pushNamed(AppRoutes.allergies);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 3 ? menuKeys![3] : null,
        title: 'Q&A Personal Kesehatan',
        icon: Bootstrap.chat_dots,
        color: AppTheme.primaryGreen,
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.healthQA);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 4 ? menuKeys![4] : null,
        title: 'Cek Interaksi Obat',
        icon: Bootstrap.shield_check,
        color: AppTheme.errorColor,
        onTap: () {
          Provider.of<ActivityProvider>(context, listen: false).logActivity(
            title: 'Cek Interaksi Obat',
            description: 'Melakukan pengecekan interaksi obat',
            iconName: 'shield_check',
          );
          Navigator.of(context).pushNamed(AppRoutes.drugInteraction);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 5 ? menuKeys![5] : null,
        title: 'Tren Grafik Kesehatan',
        icon: Bootstrap.bar_chart,
        color: AppTheme.primaryPurple,
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.healthTrends);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 6 ? menuKeys![6] : null,
        title: 'Kalkulator Kesehatan',
        icon: Bootstrap.calculator,
        color: AppTheme.buttonGreen,
        onTap: () {
          Provider.of<ActivityProvider>(context, listen: false).logActivity(
            title: 'Kalkulator Kesehatan',
            description: 'Membuka halaman Kalkulator Kesehatan',
            iconName: 'calculator',
          );
          Navigator.of(context).pushNamed(AppRoutes.healthCalculator);
        },
      ),
      _MenuItem(
        itemKey: menuKeys != null && menuKeys!.length > 7 ? menuKeys![7] : null,
        title: 'BMI & Monitoring',
        icon: Bootstrap.speedometer2,
        color: AppTheme.buttonGreen,
        onTap: () {
          Provider.of<ActivityProvider>(context, listen: false).logActivity(
            title: 'Hitung BMI',
            description: 'Membuka halaman BMI & Self Monitoring',
            iconName: 'speedometer2',
          );
          Navigator.of(context).pushNamed(AppRoutes.bmiMonitoring);
        },
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) => menuItems[index],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final GlobalKey? itemKey;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _MenuItem({
    this.itemKey,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      key: itemKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
