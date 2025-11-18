import 'package:flutter/material.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/presentation/pages/splash/splash_page.dart';
import 'package:apps/presentation/pages/auth/login/login_page.dart';
import 'package:apps/presentation/pages/auth/register/register_page.dart';
import 'package:apps/presentation/pages/dashboard/main_navigation_page.dart';
import 'package:apps/presentation/pages/news/news_detail_page.dart';
import 'package:apps/presentation/pages/profile/profile_page.dart';
import 'package:apps/presentation/pages/medical/medical_summary_page.dart';
import 'package:apps/presentation/pages/medical/medication_explanation_page.dart';
import 'package:apps/presentation/pages/medical/health_qa_page.dart';
import 'package:apps/presentation/pages/medical/allergies_page.dart';
import 'package:apps/presentation/pages/medical/drug_interaction_page.dart';
import 'package:apps/presentation/pages/health/health_trends_page.dart';
import 'package:apps/presentation/pages/health/bmi_monitoring_page.dart';
import 'package:apps/presentation/pages/health/health_calculator_menu_page.dart';
import 'package:apps/presentation/pages/health/calculators/bmi_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/bmr_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/tdee_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/body_fat_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/max_heart_rate_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/daily_calories_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/waist_to_hip_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/ideal_weight_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/water_needs_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/waist_to_height_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/body_surface_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/target_heart_rate_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/map_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/macronutrients_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/body_water_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/metabolic_age_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/one_rep_max_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/calories_burned_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/vo2_max_calculator_page.dart';
import 'package:apps/presentation/pages/health/calculators/recovery_time_calculator_page.dart';
import 'package:apps/presentation/pages/settings/edit_profile_page.dart';
import 'package:apps/presentation/pages/settings/notifications_page.dart';
import 'package:apps/presentation/pages/settings/security_page.dart';
import 'package:apps/presentation/pages/settings/language_page.dart';
import 'package:apps/presentation/pages/settings/help_page.dart';
import 'package:apps/presentation/pages/settings/about_page.dart';
import 'package:apps/domain/entities/news_article.dart';

/// Router untuk navigasi aplikasi
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );
      
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationPage(),
        );
      
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );
      
      case AppRoutes.newsDetail:
        final article = settings.arguments as NewsArticle;
        return MaterialPageRoute(
          builder: (_) => NewsDetailPage(article: article),
        );
      
      // Menu Layanan Routes
      case AppRoutes.medicalSummary:
        return MaterialPageRoute(
          builder: (_) => const MedicalSummaryPage(),
        );
      
      case AppRoutes.medicationExplanation:
        return MaterialPageRoute(
          builder: (_) => const MedicationExplanationPage(),
        );
      
      case AppRoutes.allergies:
        return MaterialPageRoute(
          builder: (_) => const AllergiesPage(),
        );
      
      case AppRoutes.healthQA:
        return MaterialPageRoute(
          builder: (_) => const HealthQAPage(),
        );
      
      case AppRoutes.drugInteraction:
        return MaterialPageRoute(
          builder: (_) => const DrugInteractionPage(),
        );
      
      case AppRoutes.healthTrends:
        return MaterialPageRoute(
          builder: (_) => const HealthTrendsPage(),
        );
      
      case AppRoutes.bmiMonitoring:
        return MaterialPageRoute(
          builder: (_) => const BMIMonitoringPage(),
        );
      
      case AppRoutes.healthCalculator:
        return MaterialPageRoute(
          builder: (_) => const HealthCalculatorMenuPage(),
        );
      
      // Calculator Routes
      case '/calculator/bmi':
        return MaterialPageRoute(
          builder: (_) => const BMICalculatorPage(),
        );
      
      case '/calculator/bmr':
        return MaterialPageRoute(
          builder: (_) => const BMRCalculatorPage(),
        );
      
      case '/calculator/tdee':
        return MaterialPageRoute(
          builder: (_) => const TDEECalculatorPage(),
        );
      
      case '/calculator/body-fat':
        return MaterialPageRoute(
          builder: (_) => const BodyFatCalculatorPage(),
        );
      
      case '/calculator/max-heart-rate':
        return MaterialPageRoute(
          builder: (_) => const MaxHeartRateCalculatorPage(),
        );
      
      case '/calculator/daily-calories':
        return MaterialPageRoute(
          builder: (_) => const DailyCaloriesCalculatorPage(),
        );
      
      case '/calculator/waist-to-hip':
        return MaterialPageRoute(
          builder: (_) => const WaistToHipCalculatorPage(),
        );
      
      case '/calculator/ideal-weight':
        return MaterialPageRoute(
          builder: (_) => const IdealWeightCalculatorPage(),
        );
      
      case '/calculator/water-needs':
        return MaterialPageRoute(
          builder: (_) => const WaterNeedsCalculatorPage(),
        );
      
      case '/calculator/waist-to-height':
        return MaterialPageRoute(
          builder: (_) => const WaistToHeightCalculatorPage(),
        );
      
      case '/calculator/body-surface':
        return MaterialPageRoute(
          builder: (_) => const BodySurfaceCalculatorPage(),
        );
      
      case '/calculator/target-heart-rate':
        return MaterialPageRoute(
          builder: (_) => const TargetHeartRateCalculatorPage(),
        );
      
      case '/calculator/map':
        return MaterialPageRoute(
          builder: (_) => const MAPCalculatorPage(),
        );
      
      case '/calculator/macronutrients':
        return MaterialPageRoute(
          builder: (_) => const MacronutrientsCalculatorPage(),
        );
      
      case '/calculator/body-water':
        return MaterialPageRoute(
          builder: (_) => const BodyWaterCalculatorPage(),
        );
      
      case '/calculator/metabolic-age':
        return MaterialPageRoute(
          builder: (_) => const MetabolicAgeCalculatorPage(),
        );
      
      case '/calculator/one-rep-max':
        return MaterialPageRoute(
          builder: (_) => const OneRepMaxCalculatorPage(),
        );
      
      case '/calculator/calories-burned':
        return MaterialPageRoute(
          builder: (_) => const CaloriesBurnedCalculatorPage(),
        );
      
      case '/calculator/vo2-max':
        return MaterialPageRoute(
          builder: (_) => const VO2MaxCalculatorPage(),
        );
      
      case '/calculator/recovery-time':
        return MaterialPageRoute(
          builder: (_) => const RecoveryTimeCalculatorPage(),
        );
      
      // Settings Routes
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
        );
      
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );
      
      case AppRoutes.security:
        return MaterialPageRoute(
          builder: (_) => const SecurityPage(),
        );
      
      case AppRoutes.language:
        return MaterialPageRoute(
          builder: (_) => const LanguagePage(),
        );
      
      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (_) => const HelpPage(),
        );
      
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => const AboutPage(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

