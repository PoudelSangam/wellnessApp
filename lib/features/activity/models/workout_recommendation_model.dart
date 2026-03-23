class WorkoutRecommendationResponse {
  final String status;
  final String userSegment;
  final String activitySegment;
  final int? rlAction;
  final String rlActionName;
  final String reason;
  final ProgramRecommendation? physicalProgram;
  final ProgramRecommendation? mentalProgram;
  final int totalActivities;
  final double userEngagement;
  final int userMotivation;

  WorkoutRecommendationResponse({
    required this.status,
    required this.userSegment,
    required this.activitySegment,
    required this.rlAction,
    required this.rlActionName,
    required this.reason,
    this.physicalProgram,
    this.mentalProgram,
    required this.totalActivities,
    required this.userEngagement,
    required this.userMotivation,
  });

  factory WorkoutRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutRecommendationResponse(
      status: (json['status'] ?? '').toString(),
      userSegment: (json['user_segment'] ?? '').toString(),
      activitySegment: (json['activity_segment'] ?? '').toString(),
      rlAction: json['rl_action'] is int
          ? json['rl_action'] as int
          : int.tryParse((json['rl_action'] ?? '').toString()),
      rlActionName: (json['rl_action_name'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      physicalProgram: json['physical_program'] != null
          ? ProgramRecommendation.fromJson(json['physical_program'])
          : null,
      mentalProgram: json['mental_program'] != null
          ? ProgramRecommendation.fromJson(json['mental_program'])
          : null,
        totalActivities: json['total_activities'] is int
          ? json['total_activities'] as int
          : int.tryParse((json['total_activities'] ?? '0').toString()) ?? 0,
        userEngagement:
          double.tryParse(
            (json['user_engagement'] ?? json['engagement_score'] ?? 0)
              .toString(),
            ) ??
            0,
        userMotivation: json['user_motivation'] is int
          ? json['user_motivation'] as int
          : int.tryParse((json['user_motivation'] ?? json['motivation_score'] ?? 0)
              .toString()) ??
            0,
    );
  }
}

class ProgramRecommendation {
  final int id;
  final String programType;
  final String name;
  final String description;
  final String segment;
  final String duration;
  final String frequency;
  final String intensity;
  final String progression;
  final String focus;
  final int? rlActionId;
  final bool completed;
  final int totalActivities;
  final int completedActivities;
  final double completionRate;
  final String createdAt;
  final List<RecommendedActivity> activities;

  ProgramRecommendation({
    required this.id,
    required this.programType,
    required this.name,
    required this.description,
    required this.segment,
    required this.duration,
    required this.frequency,
    required this.intensity,
    required this.progression,
    required this.focus,
    required this.rlActionId,
    required this.completed,
    required this.totalActivities,
    required this.completedActivities,
    required this.completionRate,
    required this.createdAt,
    required this.activities,
  });

  factory ProgramRecommendation.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'];
    return ProgramRecommendation(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? json['program_id'] ?? 0).toString()) ??
              0,
      programType: (json['program_type'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      segment: (json['segment'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      frequency: (json['frequency'] ?? '').toString(),
      intensity: (json['intensity'] ?? '').toString(),
      progression: (json['progression'] ?? '').toString(),
      focus: (json['focus'] ?? '').toString(),
      rlActionId: json['rl_action_id'] is int
          ? json['rl_action_id'] as int
          : int.tryParse((json['rl_action_id'] ?? '').toString()),
      completed: json['completed'] == true,
        totalActivities: json['total_activities'] is int
          ? json['total_activities'] as int
          : int.tryParse((json['total_activities'] ?? 0).toString()) ?? 0,
        completedActivities: json['completed_activities'] is int
          ? json['completed_activities'] as int
          : int.tryParse((json['completed_activities'] ?? 0).toString()) ?? 0,
        completionRate:
          double.tryParse((json['completion_rate'] ?? 0).toString()) ?? 0,
      createdAt: (json['created_at'] ?? '').toString(),
      activities: rawActivities is List
          ? rawActivities
              .whereType<Map<String, dynamic>>()
              .map(RecommendedActivity.fromJson)
              .toList()
          : const [],
    );
  }

  List<String> get activityNames => activities.map((e) => e.name).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_type': programType,
      'name': name,
      'description': description,
      'segment': segment,
      'duration': duration,
      'frequency': frequency,
      'intensity': intensity,
      'progression': progression,
      'focus': focus,
      'rl_action_id': rlActionId,
      'completed': completed,
      'total_activities': totalActivities,
      'completed_activities': completedActivities,
      'completion_rate': completionRate,
      'created_at': createdAt,
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }
}

class RecommendedActivity {
  final int id;
  final int programId;
  final String name;
  final String activityType;
  final String description;
  final int durationMinutes;
  final String intensity;
  final List<String> instructions;
  final int durationSeconds;
  final bool completed;

  RecommendedActivity({
    required this.id,
    required this.programId,
    required this.name,
    required this.activityType,
    required this.description,
    required this.durationMinutes,
    required this.intensity,
    required this.instructions,
    required this.durationSeconds,
    required this.completed,
  });

  factory RecommendedActivity.fromJson(Map<String, dynamic> json) {
    return RecommendedActivity(
      id: json['id'] is int
        ? json['id'] as int
        : int.tryParse((json['id'] ?? json['activity_id'] ?? 0).toString()) ??
          0,
      programId: json['program_id'] is int
        ? json['program_id'] as int
        : int.tryParse((json['program_id'] ?? 0).toString()) ?? 0,
      name: (json['activity_name'] ?? '').toString(),
      activityType: (json['activity_type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      durationMinutes: json['duration_minutes'] is int
        ? json['duration_minutes'] as int
        : int.tryParse((json['duration_minutes'] ?? 0).toString()) ?? 0,
      intensity: (json['intensity'] ?? '').toString(),
      instructions: (json['instructions'] as List?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList() ??
        const [],
      durationSeconds: json['duration_seconds'] is int
        ? json['duration_seconds'] as int
        : int.tryParse((json['duration_seconds'] ?? 0).toString()) ?? 0,
      completed: json['completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'activity_name': name,
      'activity_type': activityType,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'instructions': instructions,
      'duration_seconds': durationSeconds,
      'completed': completed,
    };
  }
}
