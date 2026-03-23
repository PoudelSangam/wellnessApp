import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      // Completed activities fetch disabled
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
                // Physical Program
                if (workoutRec.physicalProgram != null)
                  ProgramCard(
                    title: workoutRec.physicalProgram!.name,
                    description: workoutRec.physicalProgram!.description,
                    items: workoutRec.physicalProgram!.activityNames,
                    duration: workoutRec.physicalProgram!.duration,
                    frequency: workoutRec.physicalProgram!.frequency,
                    intensity: workoutRec.physicalProgram!.intensity,
                    focus: workoutRec.physicalProgram!.focus.isEmpty
                        ? null
                        : workoutRec.physicalProgram!.focus,
                    icon: Icons.fitness_center,
                    color: AppTheme.primaryColor,
                    programType: 'physical',
                    itemIds: workoutRec.physicalProgram!.activities
                        .map((e) => e.id.toString())
                        .toList(),
                    onItemTap: (activityId) {
                      context.push('/activity/detail/$activityId');
                    },
                  ),
                
                const SizedBox(height: 16),
                
                // Mental Program
                if (workoutRec.mentalProgram != null)
                  ProgramCard(
                    title: workoutRec.mentalProgram!.name,
                    description: workoutRec.mentalProgram!.description,
                    items: workoutRec.mentalProgram!.activityNames,
                    duration: workoutRec.mentalProgram!.duration,
                    frequency: workoutRec.mentalProgram!.frequency,
                    intensity: workoutRec.mentalProgram!.intensity,
                    focus: workoutRec.mentalProgram!.focus.isEmpty
                        ? null
                        : workoutRec.mentalProgram!.focus,
                    icon: Icons.psychology,
                    color: Colors.purple,
                    programType: 'mental',
                    itemIds: workoutRec.mentalProgram!.activities
                        .map((e) => e.id.toString())
                        .toList(),
                    onItemTap: (activityId) {
                      context.push('/activity/detail/$activityId');
                    },
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
                              const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
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
                                    const Icon(Icons.alarm, color: Colors.orange, size: 20),
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

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                    'No workout recommendation yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull to refresh to load your physical and mental programs.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
