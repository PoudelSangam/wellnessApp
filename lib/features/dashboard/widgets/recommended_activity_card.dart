import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../activity/models/activity_model.dart';

class RecommendedActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const RecommendedActivityCard({
    super.key,
    required this.activity,
  });

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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mental':
        return Icons.psychology;
      case 'physical':
        return Icons.fitness_center;
      case 'breathing':
        return Icons.air;
      case 'meditation':
        return Icons.self_improvement;
      case 'yoga':
        return Icons.accessibility_new;
      default:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(activity.category);

    return Card(
      child: InkWell(
        onTap: () {
          context.push('/home/activity/detail/${activity.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: categoryColor,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Activity Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.access_time,
                          '${activity.duration} min',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.signal_cellular_alt,
                          activity.difficulty,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
