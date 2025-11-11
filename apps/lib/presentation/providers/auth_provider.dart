import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/user.dart';
import 'package:apps/domain/usecases/auth/login_usecase.dart';
import 'package:apps/domain/usecases/auth/register_usecase.dart';

/// Provider untuk state management authentication
class AuthProvider extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final RegisterUsecase? registerUsecase;
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  bool _isAuthenticated = false;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  
  AuthProvider(this.loginUsecase, {this.registerUsecase});
  
  /// Set user yang sudah login
  void setUser(User? user) {
    _user = user;
    _isAuthenticated = user != null;
    notifyListeners();
  }
  
  /// Login dengan email dan password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await loginUsecase(email, password);
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (user) {
        _user = user;
        _isAuthenticated = true;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// Register dengan email, password, dan name
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  }) async {
    if (registerUsecase == null) {
      _errorMessage = 'Register usecase tidak tersedia';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await registerUsecase!(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      ktpNumber: ktpNumber,
      kkNumber: kkNumber,
    );
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (user) {
        _user = user;
        _isAuthenticated = true;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// Logout
  void logout() {
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

