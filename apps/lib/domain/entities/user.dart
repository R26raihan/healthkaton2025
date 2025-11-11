/// User entity - Business object untuk user
class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImage;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImage,
  });
}

