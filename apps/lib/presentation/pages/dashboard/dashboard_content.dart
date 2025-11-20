import 'package:flutter/material.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_menu.dart';

/// Dashboard Content - Konten utama dashboard
class DashboardContent extends StatelessWidget {
  final List<GlobalKey>? menuKeys;
  
  const DashboardContent({
    super.key,
    this.menuKeys,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Menu Layanan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          DashboardMenu(menuKeys: menuKeys),
        ],
      ),
    );
  }
}

