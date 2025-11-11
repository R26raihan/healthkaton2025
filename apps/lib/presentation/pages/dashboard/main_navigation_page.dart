import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/assets/assets.dart';
import 'package:apps/presentation/providers/auth_provider.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_header.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_content.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_news.dart';
import 'package:apps/presentation/pages/dashboard/dashboard_history.dart';
import 'package:apps/presentation/pages/medical/medical_summary_page.dart';
import 'package:apps/presentation/pages/profile/profile_page.dart';
import 'package:apps/presentation/widgets/chatbot_wrapper.dart';

/// Main Navigation Page - Halaman utama dengan bottom navigation
class MainNavigationPage extends StatefulWidget {
  static const String routeName = AppRoutes.home;
  
  const MainNavigationPage({super.key});
  
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const _DashboardTab(),
    const MedicalSummaryPage(),
    const ProfilePage(),
  ];
  
  String? _getPageContext() {
    switch (_currentIndex) {
      case 0:
        return 'dashboard';
      case 1:
        return 'medical-summary';
      case 2:
        return 'profile';
      default:
        return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final pageContext = _getPageContext();
    // Jangan tampilkan chat dialog di halaman profile
    final bool showChatbot = _currentIndex != 2; // 2 adalah index untuk ProfilePage
    
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: showChatbot
          ? ChatbotFAB(
              key: ValueKey(pageContext), // Key berubah saat context berubah
              pageContext: pageContext,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.buttonGreen,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AppAssets.medicalPrescription,
              width: 24,
              height: 24,
            ),
            activeIcon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppTheme.buttonGreen,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                AppAssets.medicalPrescription,
                width: 24,
                height: 24,
              ),
            ),
            label: 'Rekam Medis',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Dashboard Tab - Tab pertama dengan header, news, dan menu
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
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
                const DashboardHistory(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

