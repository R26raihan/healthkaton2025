import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/presentation/providers/auth_provider.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_header.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_content.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_news.dart';

/// Dashboard Page - Halaman utama setelah login
class DashboardPage extends StatelessWidget {
  static const String routeName = AppRoutes.home;
  
  const DashboardPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh dashboard data
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(user: authProvider.user),
                    const DashboardNews(),
                    const DashboardContent(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

