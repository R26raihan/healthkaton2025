import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/user.dart';

/// Provider untuk state management dashboard
class DashboardProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  
  /// Set current user
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }
  
  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

