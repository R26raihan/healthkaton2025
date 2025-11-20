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
import 'package:apps/presentation/widgets/onboarding_tutorial_widget.dart';
import 'package:apps/core/services/tutorial_service.dart';

/// Main Navigation Page - Halaman utama dengan bottom navigation
class MainNavigationPage extends StatefulWidget {
  static const String routeName = AppRoutes.home;
  
  const MainNavigationPage({super.key});
  
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  // GlobalKeys untuk tutorial
  final List<GlobalKey> _menuKeys = List.generate(8, (index) => GlobalKey());
  final GlobalKey _chatbotKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  
  final List<Widget> _pages = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize pages dengan menu keys
    _pages.add(_DashboardTab(menuKeys: _menuKeys, headerKey: _headerKey));
    _pages.add(const MedicalSummaryPage());
    _pages.add(const ProfilePage());
    
    // Check dan tampilkan tutorial jika belum pernah ditampilkan
    _checkAndShowTutorial();
  }
  
  Future<void> _checkAndShowTutorial() async {
    final hasShown = await TutorialService.hasShownTutorial();
    if (!hasShown && mounted) {
      // Tunggu sampai UI selesai render
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await OnboardingTutorialWidget.showTutorial(
            context: context,
            menuKeys: _menuKeys,
            chatbotKey: _chatbotKey,
            bottomNavKey: _bottomNavKey,
            headerKey: _headerKey,
          );
        }
      });
    }
  }
  
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
              key: _chatbotKey,
              pageContext: pageContext,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavKey,
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
  final List<GlobalKey>? menuKeys;
  final GlobalKey? headerKey;
  
  const _DashboardTab({
    this.menuKeys,
    this.headerKey,
  });
  
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
                Container(
                  key: headerKey,
                  child: DashboardHeader(user: authProvider.user),
                ),
                const DashboardNews(),
                DashboardContent(menuKeys: menuKeys),
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

