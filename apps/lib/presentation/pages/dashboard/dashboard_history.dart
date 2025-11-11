import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:apps/presentation/providers/activity_provider.dart';
import 'package:apps/domain/entities/user_activity.dart';

/// Dashboard History - Menampilkan history aktivitas user
class DashboardHistory extends StatelessWidget {
  const DashboardHistory({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        if (activityProvider.activities.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History Aktivitas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityProvider.activities.length > 5 
                    ? 5 
                    : activityProvider.activities.length,
                itemBuilder: (context, index) {
                  final activity = activityProvider.activities[index];
                  return _ActivityItem(activity: activity);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final UserActivity activity;
  
  const _ActivityItem({
    required this.activity,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            _getIcon(activity.iconName),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          activity.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(activity.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        dense: true,
      ),
    );
  }
  
  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'capsule':
        return Bootstrap.capsule;
      case 'speedometer2':
        return Bootstrap.speedometer2;
      case 'activity':
        return Bootstrap.activity;
      case 'shield_check':
        return Bootstrap.shield_check;
      case 'droplet':
        return Bootstrap.droplet;
      case 'file_medical':
        return Bootstrap.file_medical;
      case 'heart_pulse':
        return Bootstrap.heart_pulse;
      case 'thermometer':
        return Bootstrap.thermometer;
      case 'newspaper':
        return Bootstrap.newspaper;
      default:
        return Bootstrap.clock_history;
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

