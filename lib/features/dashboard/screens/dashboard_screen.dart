import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../activity/providers/activity_provider.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final activityProvider = context.read<ActivityProvider>();
    
    await Future.wait([
      dashboardProvider.fetchDashboardData(),
      activityProvider.fetchRecommendations(),
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
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

                      // Show message if exists
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
}
