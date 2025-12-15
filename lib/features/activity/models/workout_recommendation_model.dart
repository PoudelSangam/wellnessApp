class WorkoutRecommendationResponse {
  final String userSegment;
  final String recommendationType;
  final String rlAction;
  final PhysicalProgram? physicalProgram;
  final MentalProgram? mentalProgram;
  final double engagementScore;
  final int motivationScore;

  WorkoutRecommendationResponse({
    required this.userSegment,
    required this.recommendationType,
    required this.rlAction,
    this.physicalProgram,
    this.mentalProgram,
    required this.engagementScore,
    required this.motivationScore,
  });

  factory WorkoutRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutRecommendationResponse(
      userSegment: json['user_segment'] ?? '',
      recommendationType: json['recommendation_type'] ?? '',
      rlAction: json['rl_action'] ?? '',
      physicalProgram: json['physical_program'] != null
          ? PhysicalProgram.fromJson(json['physical_program'])
          : null,
      mentalProgram: json['mental_program'] != null
          ? MentalProgram.fromJson(json['mental_program'])
          : null,
      engagementScore: (json['engagement_score'] ?? 0).toDouble(),
      motivationScore: json['motivation_score'] ?? 0,
    );
  }
}

class PhysicalProgram {
  final String name;
  final String description;
  final List<String> exercises;
  final String duration;
  final String frequency;
  final String intensity;

  PhysicalProgram({
    required this.name,
    required this.description,
    required this.exercises,
    required this.duration,
    required this.frequency,
    required this.intensity,
  });

  factory PhysicalProgram.fromJson(Map<String, dynamic> json) {
    return PhysicalProgram(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      exercises: (json['exercises'] as List?)?.cast<String>() ?? [],
      duration: json['duration'] ?? '',
      frequency: json['frequency'] ?? '',
      intensity: json['intensity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'exercises': exercises,
      'duration': duration,
      'frequency': frequency,
      'intensity': intensity,
    };
  }
}

class MentalProgram {
  final String name;
  final List<String> activities;
  final String duration;
  final String frequency;

  MentalProgram({
    required this.name,
    required this.activities,
    required this.duration,
    required this.frequency,
  });

  factory MentalProgram.fromJson(Map<String, dynamic> json) {
    return MentalProgram(
      name: json['name'] ?? '',
      activities: (json['activities'] as List?)?.cast<String>() ?? [],
      duration: json['duration'] ?? '',
      frequency: json['frequency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activities': activities,
      'duration': duration,
      'frequency': frequency,
    };
  }
}
