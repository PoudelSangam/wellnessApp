import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';
import '../models/comprehensive_stats_model.dart';

class ComprehensiveStatsScreen extends StatefulWidget {
  const ComprehensiveStatsScreen({super.key});

  @override
  State<ComprehensiveStatsScreen> createState() => _ComprehensiveStatsScreenState();
}

class _ComprehensiveStatsScreenState extends State<ComprehensiveStatsScreen> {
  String _selectedPeriod = '7days';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final List<Map<String, String>> _periods = [
    {'value': '7days', 'label': '7 Days'},
    {'value': '30days', 'label': '30 Days'},
    {'value': '90days', 'label': '90 Days'},
    {'value': 'all', 'label': 'All Time'},
    {'value': 'custom', 'label': 'Custom'},
  ];

  @override
  void initState() {
    super.initState();
    // Clear any cached data and load fresh stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StatsProvider>();
      provider.clearStats();
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    final provider = context.read<StatsProvider>();
    await provider.fetchComprehensiveStats(
      period: _selectedPeriod,
      startDate: _customStartDate,
      endDate: _customEndDate,
      forceRefresh: true,
    );
  }

  Future<void> _selectCustomPeriod() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedPeriod = 'custom';
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: Consumer<StatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading statistics',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.comprehensiveStats;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: _loadStats,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),
                  _buildDateRangeInfo(stats),
                  const SizedBox(height: 24),
                  _buildOverviewCards(stats.overview),
                  const SizedBox(height: 24),
                  _buildEngagementCard(stats.engagement),
                  const SizedBox(height: 24),
                  _buildActivityBreakdown(stats.activityBreakdown),
                  const SizedBox(height: 24),
                  _buildDailyActivityChart(stats.dailyActivityCount),
                  const SizedBox(height: 24),
                  _buildDailyDurationChart(stats.dailyDuration),
                  const SizedBox(height: 24),
                  _buildMotivationTrends(stats.motivationTrends),
                  const SizedBox(height: 24),
                  _buildRatings(stats.ratings),
                  const SizedBox(height: 24),
                  _buildGoalProgress(stats.goalProgress),
                  const SizedBox(height: 24),
                  _buildRecentActivities(stats.recentActivities),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _periods.map((period) {
                final isSelected = _selectedPeriod == period['value'];
                return ChoiceChip(
                  label: Text(period['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      if (period['value'] == 'custom') {
                        _selectCustomPeriod();
                      } else {
                        setState(() {
                          _selectedPeriod = period['value']!;
                        });
                        _loadStats();
                      }
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeInfo(ComprehensiveStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('MMM d, yyyy').format(stats.startDate)} - ${DateFormat('MMM d, yyyy').format(stats.endDate)}',
            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(StatsOverview overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Activities',
              overview.totalActivities.toString(),
              Icons.fitness_center,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Duration',
              '${overview.totalDuration} min',
              Icons.timer,
              Colors.green,
            ),
            _buildStatCard(
              'Avg Duration',
              '${overview.averageDuration.toStringAsFixed(1)} min',
              Icons.analytics,
              Colors.orange,
            ),
            _buildStatCard(
              'Goal Rate',
              '${overview.goalCompletionRate.toStringAsFixed(1)}%',
              Icons.flag,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(EngagementStats engagement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEngagementStat(
                  'Active Days',
                  '${engagement.activedays}/${engagement.totalDays}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildEngagementStat(
                  'Engagement',
                  '${engagement.engagementRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildEngagementStat(
                  'Current Streak',
                  '${engagement.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  Widget _buildActivityBreakdown(Map<String, int> breakdown) {
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final total = breakdown.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return const SizedBox.shrink(); // Avoid division by zero

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...breakdown.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final percentage = (item.value / total * 100);
              final color = colors[index % colors.length];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item.value} (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? (item.value / total) : 0,
                      backgroundColor: Colors.grey[200],
                      color: color,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyActivityChart(List<DailyActivityCount> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Ensure we have valid data points
    final validData = data.where((item) => item.date.isNotEmpty).toList();
    if (validData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Activity Count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: validData.length > 7 ? (validData.length / 7).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= validData.length || value.toInt() < 0) {
                            return const Text('');
                          }
                          final date = DateTime.tryParse(validData[value.toInt()].date);
                          if (date == null) return const Text('');
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: validData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.count.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDurationChart(List<DailyDuration> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Ensure we have valid data points
    final validData = data.where((item) => item.date.isNotEmpty).toList();
    if (validData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Duration (minutes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  barGroups: validData
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.duration.toDouble(),
                              color: Colors.green,
                              width: 16,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: validData.length > 7 ? (validData.length / 7).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= validData.length || value.toInt() < 0) {
                            return const Text('');
                          }
                          final date = DateTime.tryParse(validData[value.toInt()].date);
                          if (date == null) return const Text('');
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationTrends(MotivationTrends trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motivation Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMotivationStat(
                  'Average',
                  trends.averageMotivation.toStringAsFixed(1),
                  Icons.show_chart,
                  Colors.purple,
                ),
                if (trends.trend.isNotEmpty)
                  _buildMotivationStat(
                    'Trend',
                    trends.trend,
                    trends.trend.toLowerCase().contains('up') 
                        ? Icons.trending_up 
                        : Icons.trending_down,
                    trends.trend.toLowerCase().contains('up') 
                        ? Colors.green 
                        : Colors.red,
                  ),
              ],
            ),
            if (trends.motivationDistribution.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...trends.motivationDistribution.entries.map((entry) {
                final total = trends.motivationDistribution.values.fold<int>(0, (sum, value) => sum + value);
                final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  Widget _buildRatings(RatingStats ratings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      ratings.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      'Average',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.numbers, color: Colors.blue, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      ratings.totalRatings.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'Total Ratings',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            if (ratings.ratingDistribution.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...ratings.ratingDistribution.entries.map((entry) {
                final total = ratings.ratingDistribution.values.fold<int>(0, (sum, value) => sum + value);
                final percentage = total > 0 ? (entry.value / total) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Row(
                          children: [
                            Text(entry.key),
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[200],
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          entry.value.toString(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(GoalProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGoalStat(
                    'Total',
                    progress.totalGoals.toString(),
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildGoalStat(
                    'Completed',
                    progress.completedGoals.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildGoalStat(
                    'In Progress',
                    progress.inProgressGoals.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion Rate: ${progress.completionPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.completionPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivities(List<RecentActivity> activities) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...activities.take(5).map((activity) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.fitness_center, color: Colors.blue),
                ),
                title: Text(activity.name),
                subtitle: Text(
                  '${activity.category} • ${activity.duration} min • ${DateFormat('MMM d, h:mm a').format(activity.completedAt)}',
                ),
                trailing: activity.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(activity.rating!.toStringAsFixed(1)),
                        ],
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
