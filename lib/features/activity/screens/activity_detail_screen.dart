import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/widgets/custom_button.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../widgets/exercise_animation_widget.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({
    super.key,
    required this.activityId,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadActivityDetail();
  }

  Future<void> _loadActivityDetail() async {
    final activityProvider = context.read<ActivityProvider>();
    await activityProvider.fetchActivityDetail(widget.activityId);
  }

  Future<void> _handleComplete() async {
    final activityProvider = context.read<ActivityProvider>();
    final success = await activityProvider.completeActivity(widget.activityId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity completed! Great job! 🎉'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activityProvider.errorMessage ?? 'Failed to complete activity',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mental':
        return AppTheme.primaryColor;
      case 'physical':
        return AppTheme.secondaryColor;
      case 'breathing':
        return Colors.blue;
      case 'meditation':
        return Colors.purple;
      case 'yoga':
        return Colors.orange;
      default:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedActivity == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final activity = provider.selectedActivity;
          if (activity == null) {
            return const Center(child: Text('Activity not found'));
          }

          final categoryColor = _getCategoryColor(activity.category);

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    activity.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: activity.imageUrl != null
                      ? Image.network(
                          activity.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor,
                                categoryColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.self_improvement,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Duration
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.category,
                            activity.category,
                            categoryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.access_time,
                            '${activity.duration} min',
                            AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.signal_cellular_alt,
                            activity.difficulty,
                            AppTheme.accentColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Exercise Animation Demo
                      ExerciseAnimationWidget(
                        exerciseName: activity.name,
                        category: activity.category,
                        duration: activity.duration,
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 24),

                      // Benefits
                      Text(
                        'Benefits',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      ...activity.benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (activity.instructions != null &&
                          activity.instructions!.isNotEmpty) ...[
                        const SizedBox(height: 24),

                        // Instructions
                        Text(
                          'How to do it',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        ...activity.instructions!.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final instruction = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Complete Button
                      CustomButton(
                        onPressed: provider.isLoading ? null : _handleComplete,
                        isLoading: provider.isLoading,
                        text: 'Complete Activity',
                        icon: Icons.check_circle,
                        backgroundColor: categoryColor,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
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
