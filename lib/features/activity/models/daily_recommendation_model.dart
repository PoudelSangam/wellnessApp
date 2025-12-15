class DailyRecommendationResponse {
  final String status;
  final String userSegment;
  final int rlAction;
  final String rlActionName;
  final String reason;
  final List<RecommendedActivity> recommendedActivities;
  final int totalActivities;
  final double userEngagement;
  final int userMotivation;

  DailyRecommendationResponse({
    required this.status,
    required this.userSegment,
    required this.rlAction,
    required this.rlActionName,
    required this.reason,
    required this.recommendedActivities,
    required this.totalActivities,
    required this.userEngagement,
    required this.userMotivation,
  });

  factory DailyRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return DailyRecommendationResponse(
      status: json['status'] ?? '',
      userSegment: json['user_segment'] ?? '',
      rlAction: json['rl_action'] ?? 0,
      rlActionName: json['rl_action_name'] ?? '',
      reason: json['reason'] ?? '',
      recommendedActivities: (json['recommended_activities'] as List?)
              ?.map((activity) => RecommendedActivity.fromJson(activity))
              .toList() ??
          [],
      totalActivities: json['total_activities'] ?? 0,
      userEngagement: (json['user_engagement'] ?? 0).toDouble(),
      userMotivation: json['user_motivation'] ?? 0,
    );
  }
}

class RecommendedActivity {
  final int id;
  final String activityName;
  final String activityType;
  final int durationMinutes;
  final String intensity;
  final String? instructions;
  final String? userSegment;
  final int? rlActionId;
  final String? assignedDate;
  final bool completed;

  RecommendedActivity({
    required this.id,
    required this.activityName,
    required this.activityType,
    required this.durationMinutes,
    required this.intensity,
    this.instructions,
    this.userSegment,
    this.rlActionId,
    this.assignedDate,
    this.completed = false,
  });

  factory RecommendedActivity.fromJson(Map<String, dynamic> json) {
    // Handle instructions - can be either List or String
    String? instructionsText;
    if (json['instructions'] != null) {
      if (json['instructions'] is List) {
        instructionsText = (json['instructions'] as List).join('\n');
      } else {
        instructionsText = json['instructions'].toString();
      }
    }
    
    return RecommendedActivity(
      id: json['id'] ?? 0,
      activityName: json['name'] ?? json['activity_name'] ?? '',
      activityType: json['type'] ?? json['activity_type'] ?? '',
      durationMinutes: json['duration'] ?? json['duration_minutes'] ?? 0,
      intensity: json['intensity'] ?? 'moderate',
      instructions: instructionsText,
      userSegment: json['user_segment'],
      rlActionId: json['rl_action_id'],
      assignedDate: json['assigned_date'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_name': activityName,
      'activity_type': activityType,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'instructions': instructions,
      'user_segment': userSegment,
      'rl_action_id': rlActionId,
      'assigned_date': assignedDate,
      'completed': completed,
    };
  }

  // Convert to ActivityModel for compatibility
  Map<String, dynamic> toActivityModel() {
    final instructionsList = instructions?.split('\n').where((s) => s.trim().isNotEmpty).toList() ?? [];
    
    return {
      'id': id.toString(),
      'name': activityName,
      'description': 'Personalized $activityType activity recommended for you',
      'category': activityType,
      'duration': durationMinutes,
      'difficulty': intensity,
      'benefits': [
        'Tailored to your wellness goals',
        'Recommended by AI system',
        'Helps improve overall well-being',
      ],
      'instructions': instructionsList,
    };
  }
}
