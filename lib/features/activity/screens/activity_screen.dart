import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/category_chip.dart';
import '../../dashboard/widgets/program_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final activityProvider = context.read<ActivityProvider>();
    await Future.wait([
      activityProvider.fetchActivities(),
      activityProvider.fetchWorkoutRecommendation(), // Use new workout recommendation
      activityProvider.fetchCompletedActivities(),
    ]);
  }

  Future<void> _handleRefresh() async {
    await _loadActivities();
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    
    final activityProvider = context.read<ActivityProvider>();
    activityProvider.fetchActivities(category: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recommended'),
            Tab(text: 'All Activities'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendedTab(),
          _buildAllActivitiesTab(),
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendedTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.workoutRecommendation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final workoutRec = provider.workoutRecommendation;

          // Show workout recommendation if exists
          if (workoutRec != null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Recommendation Header Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.15),
                          AppTheme.secondaryColor.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI-Powered Recommendation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    workoutRec.rlAction,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: AppTheme.accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  workoutRec.userSegment,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildScoreCard(
                                'Engagement',
                                '${(workoutRec.engagementScore * 100).toInt()}%',
                                Icons.trending_up,
                                AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildScoreCard(
                                'Motivation',
                                'Level ${workoutRec.motivationScore}',
                                Icons.favorite,
                                AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Physical Program
                if (workoutRec.physicalProgram != null)
                  ProgramCard(
                    title: workoutRec.physicalProgram!.name,
                    description: workoutRec.physicalProgram!.description,
                    items: workoutRec.physicalProgram!.exercises,
                    duration: workoutRec.physicalProgram!.duration,
                    frequency: workoutRec.physicalProgram!.frequency,
                    intensity: workoutRec.physicalProgram!.intensity,
                    icon: Icons.fitness_center,
                    color: AppTheme.primaryColor,
                    programType: 'physical',
                  ),
                
                const SizedBox(height: 16),
                
                // Mental Program
                if (workoutRec.mentalProgram != null)
                  ProgramCard(
                    title: workoutRec.mentalProgram!.name,
                    description: 'Mental wellness activities',
                    items: workoutRec.mentalProgram!.activities,
                    duration: workoutRec.mentalProgram!.duration,
                    frequency: workoutRec.mentalProgram!.frequency,
                    icon: Icons.psychology,
                    color: Colors.purple,
                    programType: 'mental',
                  ),
                
                const SizedBox(height: 16),
                
                // Reminders section
                if (provider.reminders != null && provider.reminders!.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Reminders',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...provider.reminders!.map((reminder) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.alarm, color: Colors.orange, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reminder,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }

          if (provider.recommendedActivities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile to get personalized recommendations',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recommendedActivities.length,
            itemBuilder: (context, index) {
              final activity = provider.recommendedActivities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(activity: activity),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllActivitiesTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => _filterByCategory(null),
                ),
                const SizedBox(width: 8),
                ...AppConstants.activityCategories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () => _filterByCategory(category),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activities List
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.activities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.activities.length,
                  itemBuilder: (context, index) {
                    final activity = provider.activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(activity: activity),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.completedActivities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.completedActivities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed activities',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your wellness journey today!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.completedActivities.length,
            itemBuilder: (context, index) {
              final completedActivity = provider.completedActivities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                  ),
                  title: Text(completedActivity.activityName),
                  subtitle: Text(
                    'Completed on ${_formatDate(completedActivity.completedAt)}',
                  ),
                  trailing: Text(
                    '${completedActivity.duration} min',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildScoreCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
