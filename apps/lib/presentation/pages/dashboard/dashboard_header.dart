import 'package:flutter/material.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/assets/assets.dart';
import 'package:apps/domain/entities/user.dart';

/// Dashboard Header - Header dengan user info dan menu
class DashboardHeader extends StatelessWidget {
  final User? user;
  
  const DashboardHeader({
    super.key,
    this.user,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                  ? Image.network(
                      user!.profileImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.backgroundGradient,
                          ),
                          child: Center(
                            child: Text(
                              user?.name != null && user!.name.isNotEmpty
                                  ? user!.name.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.backgroundGradient,
                      ),
                      child: Center(
                        child: Text(
                          user?.name != null && user!.name.isNotEmpty
                              ? user!.name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Andya Raihan Setiawan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Logo
          Container(
            constraints: const BoxConstraints(
              maxWidth: 100,
              maxHeight: 100,
            ),
            child: Image.asset(
              AppAssets.logoHealth,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

