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
    _loadActivities();
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
      activityProvider.fetchRecommendations(),
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
          if (provider.isLoading && provider.recommendedActivities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show workout recommendation if exists
          if (provider.physicalProgram != null || provider.mentalProgram != null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info message
                if (provider.recommendationMessage != null && provider.recommendationMessage!.isNotEmpty)
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
                              provider.recommendationMessage!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Physical Program
                if (provider.physicalProgram != null)
                  ProgramCard(
                    title: provider.physicalProgram!['name'] ?? 'Physical Program',
                    description: provider.physicalProgram!['description'] ?? '',
                    items: (provider.physicalProgram!['exercises'] as List?)?.cast<String>() ?? [],
                    duration: provider.physicalProgram!['duration'] ?? 'N/A',
                    frequency: provider.physicalProgram!['frequency'] ?? 'N/A',
                    intensity: provider.physicalProgram!['intensity'],
                    icon: Icons.fitness_center,
                    color: AppTheme.primaryColor,
                  ),
                
                const SizedBox(height: 16),
                
                // Mental Program
                if (provider.mentalProgram != null)
                  ProgramCard(
                    title: provider.mentalProgram!['name'] ?? 'Mental Program',
                    description: provider.mentalProgram!['description'] ?? '',
                    items: (provider.mentalProgram!['activities'] as List?)?.cast<String>() ?? [],
                    duration: provider.mentalProgram!['duration'] ?? 'N/A',
                    frequency: provider.mentalProgram!['frequency'] ?? 'N/A',
                    focus: provider.mentalProgram!['focus'],
                    icon: Icons.psychology,
                    color: Colors.purple,
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
}
