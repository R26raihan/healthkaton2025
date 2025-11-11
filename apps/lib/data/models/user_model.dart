import 'package:apps/domain/entities/user.dart';

/// User Model untuk JSON serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    super.profileImage,
  });
  
  /// Convert dari JSON (dari backend API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Backend menggunakan camelCase: phoneNumber
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
      profileImage: json['profileImage']?.toString() ?? json['profile_image']?.toString(),
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
    };
  }
  
  /// Convert dari Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profileImage: user.profileImage,
    );
  }
}

