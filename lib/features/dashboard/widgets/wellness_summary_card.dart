import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../stats/providers/stats_provider.dart';

class WellnessSummaryCard extends StatelessWidget {
  const WellnessSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final stats = statsProvider.comprehensiveStats;
    final isLoading = statsProvider.isLoading && stats == null;

    final completed = stats?.overview.totalActivities ?? 0;
    final assigned = stats?.overview.totalGoalsSet ?? 0;
    final durationMin = stats?.overview.totalDuration ?? 0;
    final rate = stats?.overview.goalCompletionRate ?? 0.0;
    final breakdown = stats?.activityBreakdown ?? {};

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wellness Summary (30 Days)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        value: '$completed / $assigned',
                      ),
                      _buildSummaryItem(
                        icon: Icons.pie_chart_outline,
                        label: 'Completion Rate',
                        value: '${rate.toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        icon: Icons.access_time,
                        label: 'Duration',
                        value: durationMin >= 60
                            ? '${(durationMin / 60).toStringAsFixed(1)} hrs'
                            : '$durationMin min',
                      ),
                      _buildSummaryItem(
                        icon: Icons.bar_chart,
                        label: 'Exercise / Meditation',
                        value:
                            '${breakdown['exercise'] ?? 0} / ${breakdown['meditation'] ?? 0}',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
