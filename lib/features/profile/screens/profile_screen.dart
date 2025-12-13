import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/home/profile/edit');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.username ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            ProfileInfoCard(
              title: 'Personal Information',
              items: [
                if (user?.age != null)
                  ProfileInfoItem(
                    icon: Icons.cake,
                    label: 'Age',
                    value: '${user!.age} years',
                  ),
                if (user?.gender != null)
                  ProfileInfoItem(
                    icon: Icons.person,
                    label: 'Gender',
                    value: user!.gender!,
                  ),
                if (user?.height != null)
                  ProfileInfoItem(
                    icon: Icons.height,
                    label: 'Height',
                    value: '${user!.height} cm',
                  ),
                if (user?.weight != null)
                  ProfileInfoItem(
                    icon: Icons.monitor_weight,
                    label: 'Weight',
                    value: '${user!.weight} kg',
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Wellness Goals
            ProfileInfoCard(
              title: 'Wellness Goals',
              items: [
                if (user?.primaryGoal != null)
                  ProfileInfoItem(
                    icon: Icons.flag,
                    label: 'Primary Goal',
                    value: user!.primaryGoal!,
                  ),
                if (user?.workoutGoalDays != null)
                  ProfileInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Workout Goal',
                    value: '${user!.workoutGoalDays} days/week',
                  ),
                if (user?.selfReportedStress != null)
                  ProfileInfoItem(
                    icon: Icons.psychology,
                    label: 'Stress Level',
                    value: user!.selfReportedStress!,
                  ),
                if (user?.physicalActivityWeek != null)
                  ProfileInfoItem(
                    icon: Icons.fitness_center,
                    label: 'Physical Activity',
                    value: '${user!.physicalActivityWeek} days/week',
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu Options
            Card(
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      context.push('/home/profile/edit');
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy Policy coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Card(
              child: ProfileMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: AppTheme.errorColor,
                titleColor: AppTheme.errorColor,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
