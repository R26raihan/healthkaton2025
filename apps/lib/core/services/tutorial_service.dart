import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialShownKey = 'tutorial_shown';
  
  /// Check apakah tutorial sudah pernah ditampilkan
  static Future<bool> hasShownTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialShownKey) ?? false;
  }
  
  /// Mark tutorial sebagai sudah ditampilkan
  static Future<void> markTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialShownKey, true);
  }
  
  /// Reset tutorial (untuk testing atau jika user ingin melihat lagi)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialShownKey, false);
  }
}

