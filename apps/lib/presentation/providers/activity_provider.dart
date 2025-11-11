import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/user_activity.dart';

/// Provider untuk mengelola history aktivitas user
class ActivityProvider extends ChangeNotifier {
  List<UserActivity> _activities = [];
  
  List<UserActivity> get activities => List.unmodifiable(_activities);
  
  /// Menambahkan aktivitas baru
  void addActivity(UserActivity activity) {
    _activities.insert(0, activity);
    
    // Batasi maksimal 20 aktivitas terakhir
    if (_activities.length > 20) {
      _activities = _activities.take(20).toList();
    }
    
    notifyListeners();
  }
  
  /// Menambahkan aktivitas berdasarkan action
  void logActivity({
    required String title,
    required String description,
    String? iconName,
  }) {
    final activity = UserActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      timestamp: DateTime.now(),
      iconName: iconName,
    );
    
    addActivity(activity);
  }
  
  /// Menghapus semua aktivitas
  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }
  
  /// Inisialisasi dengan data sample (untuk demo)
  void initializeSampleData() {
    _activities = [
      UserActivity(
        id: '1',
        title: 'Mencatat Konsumsi Obat',
        description: 'Paracetamol 500mg - Pagi, Siang, Malam',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        iconName: 'capsule',
      ),
      UserActivity(
        id: '2',
        title: 'Hitung BMI',
        description: 'BMI: 22.5 (Normal) - Berat: 65kg, Tinggi: 170cm',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        iconName: 'speedometer2',
      ),
      UserActivity(
        id: '3',
        title: 'Cek Kolesterol',
        description: 'Kolesterol Total: 180 mg/dL (Normal)',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        iconName: 'activity',
      ),
      UserActivity(
        id: '4',
        title: 'Cek Interaksi Obat',
        description: 'Paracetamol + Ibuprofen - Aman dikonsumsi',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        iconName: 'shield_check',
      ),
      UserActivity(
        id: '5',
        title: 'Cek Gula Darah',
        description: 'Gula Darah Puasa: 95 mg/dL (Normal)',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        iconName: 'droplet',
      ),
    ];
    notifyListeners();
  }
}

