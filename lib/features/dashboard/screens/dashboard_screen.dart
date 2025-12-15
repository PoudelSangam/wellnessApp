import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../activity/providers/activity_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../widgets/wellness_summary_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/recommended_activity_card.dart';
import '../widgets/motivational_quote_card.dart';
import '../widgets/program_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final activityProvider = context.read<ActivityProvider>();
    
    await Future.wait([
      dashboardProvider.fetchDashboardData(),
      activityProvider.fetchDailyRecommendations(), // Use new daily recommendations
    ]);
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.username ?? 'User'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final unreadCount = provider.unreadCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount.toString()),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  context.go('/notifications');
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.dashboardData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wellness Summary
                  const WellnessSummaryCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Indicators
                  const ProgressCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Today's Recommendations
                  Text(
                    "Today's Recommendations",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Consumer<ActivityProvider>(
                    builder: (context, activityProvider, _) {
                      if (activityProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final dailyRec = activityProvider.dailyRecommendation;

                      // Show daily recommendation info if available
                      if (dailyRec != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recommendation Header Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.1),
                                      AppTheme.secondaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dailyRec.rlActionName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dailyRec.userSegment,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lightbulb_outline,
                                            color: AppTheme.accentColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              dailyRec.reason,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatChip(
                                          Icons.fitness_center,
                                          '${dailyRec.totalActivities} Activities',
                                          AppTheme.primaryColor,
                                        ),
                                        _buildStatChip(
                                          Icons.trending_up,
                                          '${(dailyRec.userEngagement * 100).toInt()}% Engaged',
                                          AppTheme.successColor,
                                        ),
                                        _buildStatChip(
                                          Icons.favorite,
                                          'Level ${dailyRec.userMotivation}',
                                          AppTheme.errorColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),

                            // Recommended Activities List
                            if (activityProvider.recommendedActivities.isNotEmpty)
                              ...activityProvider.recommendedActivities.map((activity) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RecommendedActivityCard(activity: activity),
                                );
                              }),

                            if (activityProvider.recommendedActivities.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No activities for today',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }

                      // Fallback to old recommendation message
                      if (activityProvider.recommendationMessage != null) {
                        return Column(
                          children: [
                            if (activityProvider.recommendationMessage!.isNotEmpty)
                              Card(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: AppTheme.primaryColor),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          activityProvider.recommendationMessage!,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Physical Program
                            if (activityProvider.physicalProgram != null)
                              ProgramCard(
                                title: activityProvider.physicalProgram!['name'] ?? 'Physical Program',
                                description: activityProvider.physicalProgram!['description'] ?? '',
                                items: (activityProvider.physicalProgram!['exercises'] as List?)?.cast<String>() ?? [],
                                duration: activityProvider.physicalProgram!['duration'] ?? 'N/A',
                                frequency: activityProvider.physicalProgram!['frequency'] ?? 'N/A',
                                intensity: activityProvider.physicalProgram!['intensity'],
                                icon: Icons.fitness_center,
                                color: AppTheme.primaryColor,
                                programType: 'physical',
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Mental Program
                            if (activityProvider.mentalProgram != null)
                              ProgramCard(
                                title: activityProvider.mentalProgram!['name'] ?? 'Mental Program',
                                description: activityProvider.mentalProgram!['description'] ?? '',
                                items: (activityProvider.mentalProgram!['activities'] as List?)?.cast<String>() ?? [],
                                duration: activityProvider.mentalProgram!['duration'] ?? 'N/A',
                                frequency: activityProvider.mentalProgram!['frequency'] ?? 'N/A',
                                focus: activityProvider.mentalProgram!['focus'],
                                icon: Icons.psychology,
                                color: Colors.purple,
                                programType: 'mental',
                              ),
                          ],
                        );
                      }

                      if (activityProvider.recommendedActivities.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.self_improvement,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No recommendations yet',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check back later for personalized activities',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: activityProvider.recommendedActivities
                            .take(3)
                            .map((activity) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RecommendedActivityCard(
                                    activity: activity,
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Motivational Quote
                  const MotivationalQuoteCard(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
