class StatsModel {
  final DateTime date;
  final int activitiesCompleted;
  final int minutesExercised;
  final int stressLevel;
  final int moodScore;
  final int sleepHours;

  StatsModel({
    required this.date,
    required this.activitiesCompleted,
    required this.minutesExercised,
    required this.stressLevel,
    required this.moodScore,
    required this.sleepHours,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      date: DateTime.parse(json['date']),
      activitiesCompleted: json['activities_completed'] ?? 0,
      minutesExercised: json['minutes_exercised'] ?? 0,
      stressLevel: json['stress_level'] ?? 5,
      moodScore: json['mood_score'] ?? 5,
      sleepHours: json['sleep_hours'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activities_completed': activitiesCompleted,
      'minutes_exercised': minutesExercised,
      'stress_level': stressLevel,
      'mood_score': moodScore,
      'sleep_hours': sleepHours,
    };
  }
}

class MoodStats {
  final Map<String, int> moodDistribution;
  final double averageMood;
  final String dominantMood;

  MoodStats({
    required this.moodDistribution,
    required this.averageMood,
    required this.dominantMood,
  });
}

class WorkStats {
  final int totalActivities;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;

  WorkStats({
    required this.totalActivities,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
  });
}
