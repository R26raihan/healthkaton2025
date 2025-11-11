import 'dart:convert';
import 'package:apps/core/constants/app_constants.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/core/storage/secure_storage_service.dart';
import 'package:apps/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source untuk menyimpan data user secara lokal
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  AuthLocalDataSourceImpl(this.sharedPreferences);
  
  @override
  Future<void> saveToken(String token) async {
    // Simpan token ke secure storage (lebih aman)
    await SecureStorageService.saveToken(token);
  }
  
  @override
  Future<String?> getToken() async {
    // Ambil token dari secure storage
    return await SecureStorageService.getToken();
  }
  
  @override
  Future<void> saveUser(UserModel user) async {
    // Simpan user data ke shared preferences (bisa juga ke secure storage jika diperlukan)
    final userJson = jsonEncode(user.toJson());
    await sharedPreferences.setString(AppConstants.userKey, userJson);
  }
  
  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString(AppConstants.userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw const CacheFailure('Gagal memuat data user');
    }
  }
  
  @override
  Future<void> clearAll() async {
    // Clear token dari secure storage
    await SecureStorageService.deleteToken();
    await SecureStorageService.deleteRefreshToken();
    // Clear medical record ID dari secure storage
    await SecureStorageService.deleteRecordId();
    // Clear user data dari shared preferences
    await sharedPreferences.remove(AppConstants.userKey);
  }
}

