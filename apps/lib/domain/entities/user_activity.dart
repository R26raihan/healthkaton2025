/// User Activity Entity - Aktivitas yang dilakukan user
class UserActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? iconName;
  
  const UserActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.iconName,
  });
}

