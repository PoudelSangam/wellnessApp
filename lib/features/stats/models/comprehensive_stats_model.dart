class ComprehensiveStatsModel {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final StatsOverview overview;
  final Map<String, int> activityBreakdown;
  final List<DailyActivityCount> dailyActivityCount;
  final List<DailyDuration> dailyDuration;
  final MotivationTrends motivationTrends;
  final EngagementStats engagement;
  final RatingStats ratings;
  final GoalProgress goalProgress;
  final List<RecentActivity> recentActivities;

  ComprehensiveStatsModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.overview,
    required this.activityBreakdown,
    required this.dailyActivityCount,
    required this.dailyDuration,
    required this.motivationTrends,
    required this.engagement,
    required this.ratings,
    required this.goalProgress,
    required this.recentActivities,
  });

  factory ComprehensiveStatsModel.fromJson(Map<String, dynamic> json) {
    // Handle activity_breakdown which may have nested structure
    Map<String, int> parseActivityBreakdown(dynamic data) {
      if (data == null) return {};
      if (data is Map<String, dynamic>) {
        final result = <String, int>{};
        data.forEach((key, value) {
          // Skip nested maps like 'duration_by_type'
          if (value is int) {
            result[key] = value;
          } else if (value is num) {
            result[key] = value.toInt();
          }
        });
        return result;
      }
      return {};
    }

    // Safe list parsing
    List<DailyActivityCount> parseDailyActivityCount(dynamic data) {
      if (data == null) return [];
      if (data is! List) return [];
      try {
        return data
            .where((item) => item is Map<String, dynamic>)
            .map((item) => DailyActivityCount.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }

    List<DailyDuration> parseDailyDuration(dynamic data) {
      if (data == null) return [];
      if (data is! List) return [];
      try {
        return data
            .where((item) => item is Map<String, dynamic>)
            .map((item) => DailyDuration.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }

    List<RecentActivity> parseRecentActivities(dynamic data) {
      if (data == null) return [];
      if (data is! List) return [];
      try {
        return data
            .where((item) => item is Map<String, dynamic>)
            .map((item) => RecentActivity.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }

    return ComprehensiveStatsModel(
      period: json['period']?.toString() ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      overview: StatsOverview.fromJson(json['overview'] is Map<String, dynamic> ? json['overview'] : {}),
      activityBreakdown: parseActivityBreakdown(json['activity_breakdown']),
      dailyActivityCount: parseDailyActivityCount(json['daily_activity_count']),
      dailyDuration: parseDailyDuration(json['daily_duration']),
      motivationTrends: MotivationTrends.fromJson(json['motivation_trends'] is Map<String, dynamic> ? json['motivation_trends'] : {}),
      engagement: EngagementStats.fromJson(json['engagement'] is Map<String, dynamic> ? json['engagement'] : {}),
      ratings: RatingStats.fromJson(json['ratings'] is Map<String, dynamic> ? json['ratings'] : {}),
      goalProgress: GoalProgress.fromJson(json['goal_progress'] is Map<String, dynamic> ? json['goal_progress'] : {}),
      recentActivities: parseRecentActivities(json['recent_activities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'overview': overview.toJson(),
      'activity_breakdown': activityBreakdown,
      'daily_activity_count': dailyActivityCount.map((e) => e.toJson()).toList(),
      'daily_duration': dailyDuration.map((e) => e.toJson()).toList(),
      'motivation_trends': motivationTrends.toJson(),
      'engagement': engagement.toJson(),
      'ratings': ratings.toJson(),
      'goal_progress': goalProgress.toJson(),
      'recent_activities': recentActivities.map((e) => e.toJson()).toList(),
    };
  }
}

class StatsOverview {
  final int totalActivities;
  final int totalDuration;
  final double averageDuration;
  final int totalGoalsSet;
  final int goalsAchieved;
  final double goalCompletionRate;

  StatsOverview({
    this.totalActivities = 0,
    this.totalDuration = 0,
    this.averageDuration = 0.0,
    this.totalGoalsSet = 0,
    this.goalsAchieved = 0,
    this.goalCompletionRate = 0.0,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    return StatsOverview(
      totalActivities: _parseInt(json['total_activities_completed'] ?? json['total_activities']),
      totalDuration: _parseInt(json['total_duration_minutes'] ?? json['total_duration']),
      averageDuration: _parseDouble(json['average_duration']),
      totalGoalsSet: _parseInt(json['total_goals_set'] ?? json['total_activities_assigned']),
      goalsAchieved: _parseInt(json['goals_achieved']),
      goalCompletionRate: _parseDouble(json['goal_completion_rate'] ?? json['completion_rate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_activities': totalActivities,
      'total_duration': totalDuration,
      'average_duration': averageDuration,
      'total_goals_set': totalGoalsSet,
      'goals_achieved': goalsAchieved,
      'goal_completion_rate': goalCompletionRate,
    };
  }
}

class DailyActivityCount {
  final String date;
  final int count;

  DailyActivityCount({
    required this.date,
    required this.count,
  });

  factory DailyActivityCount.fromJson(Map<String, dynamic> json) {
    return DailyActivityCount(
      date: json['date']?.toString() ?? '',
      count: _parseInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
    };
  }
}

class DailyDuration {
  final String date;
  final int duration;

  DailyDuration({
    required this.date,
    required this.duration,
  });

  factory DailyDuration.fromJson(Map<String, dynamic> json) {
    return DailyDuration(
      date: json['date']?.toString() ?? '',
      duration: _parseInt(json['duration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'duration': duration,
    };
  }
}

class MotivationTrends {
  final double averageMotivation;
  final String trend;
  final Map<String, int> motivationDistribution;

  MotivationTrends({
    this.averageMotivation = 0.0,
    this.trend = '',
    this.motivationDistribution = const {},
  });

  factory MotivationTrends.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseDistribution(dynamic data) {
      if (data == null) return {};
      if (data is Map<String, dynamic>) {
        final result = <String, int>{};
        data.forEach((key, value) {
          if (value is int) {
            result[key] = value;
          } else if (value is num) {
            result[key] = value.toInt();
          }
        });
        return result;
      }
      return {};
    }

    return MotivationTrends(
      averageMotivation: _parseDouble(json['average_motivation']),
      trend: json['trend']?.toString() ?? '',
      motivationDistribution: parseDistribution(json['motivation_distribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_motivation': averageMotivation,
      'trend': trend,
      'motivation_distribution': motivationDistribution,
    };
  }
}

class EngagementStats {
  final int activedays;
  final int totalDays;
  final double engagementRate;
  final int currentStreak;
  final int longestStreak;

  EngagementStats({
    this.activedays = 0,
    this.totalDays = 0,
    this.engagementRate = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory EngagementStats.fromJson(Map<String, dynamic> json) {
    return EngagementStats(
      activedays: _parseInt(json['active_days']),
      totalDays: _parseInt(json['total_days']),
      engagementRate: _parseDouble(json['engagement_rate']),
      currentStreak: _parseInt(json['current_streak']),
      longestStreak: _parseInt(json['longest_streak']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_days': activedays,
      'total_days': totalDays,
      'engagement_rate': engagementRate,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }
}

class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution;

  RatingStats({
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.ratingDistribution = const {},
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseDistribution(dynamic data) {
      if (data == null) return {};
      if (data is Map<String, dynamic>) {
        final result = <String, int>{};
        data.forEach((key, value) {
          if (value is int) {
            result[key] = value;
          } else if (value is num) {
            result[key] = value.toInt();
          }
        });
        return result;
      }
      return {};
    }

    return RatingStats(
      averageRating: _parseDouble(json['average_rating']),
      totalRatings: _parseInt(json['total_ratings']),
      ratingDistribution: parseDistribution(json['rating_distribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'rating_distribution': ratingDistribution,
    };
  }
}

class GoalProgress {
  final int totalGoals;
  final int completedGoals;
  final int inProgressGoals;
  final double completionPercentage;

  GoalProgress({
    this.totalGoals = 0,
    this.completedGoals = 0,
    this.inProgressGoals = 0,
    this.completionPercentage = 0.0,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      totalGoals: _parseInt(json['total_goals']),
      completedGoals: _parseInt(json['completed_goals']),
      inProgressGoals: _parseInt(json['in_progress_goals']),
      completionPercentage: _parseDouble(json['completion_percentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_goals': totalGoals,
      'completed_goals': completedGoals,
      'in_progress_goals': inProgressGoals,
      'completion_percentage': completionPercentage,
    };
  }
}

class RecentActivity {
  final int id;
  final String name;
  final String category;
  final int duration;
  final DateTime completedAt;
  final double? rating;
  final String? motivationLevel;

  RecentActivity({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.completedAt,
    this.rating,
    this.motivationLevel,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      duration: _parseInt(json['duration']),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      motivationLevel: json['motivation_level']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'duration': duration,
      'completed_at': completedAt.toIso8601String(),
      'rating': rating,
      'motivation_level': motivationLevel,
    };
  }
}

// Helper functions to safely parse values
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
