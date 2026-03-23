class ActivityModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final int duration; // in minutes
  final int? durationSeconds; // exact duration from API when available
  final String difficulty;
  final List<String> benefits;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? instructions;
  
  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    this.durationSeconds,
    required this.difficulty,
    required this.benefits,
    this.imageUrl,
    this.videoUrl,
    this.instructions,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final rawBenefits = json['benefits'];
    final rawInstructions = json['instructions'];

    return ActivityModel(
      id: (json['id'] ?? json['activity_id'] ?? '').toString(),
      name: (json['name'] ?? json['activity_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category:
          (json['category'] ?? json['activity_type'] ?? 'workout').toString(),
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse((json['duration_minutes'] ?? json['duration'] ?? 0)
                  .toString()) ??
              0,
        durationSeconds: json['durationSeconds'] is int
          ? json['durationSeconds'] as int
          : int.tryParse((json['duration_seconds'] ?? '').toString()),
      difficulty: (json['difficulty'] ?? json['intensity'] ?? 'Moderate')
          .toString(),
      benefits: rawBenefits is List
          ? rawBenefits
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? json['video_url']?.toString(),
      instructions: rawInstructions is List
          ? rawInstructions
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'duration': duration,
      'durationSeconds': durationSeconds,
      'difficulty': difficulty,
      'benefits': benefits,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions,
    };
  }
}

class CompletedActivity {
  final String id;
  final String activityId;
  final String activityName;
  final DateTime completedAt;
  final int duration;
  final String? notes;
  
  CompletedActivity({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.completedAt,
    required this.duration,
    this.notes,
  });

  factory CompletedActivity.fromJson(Map<String, dynamic> json) {
    return CompletedActivity(
      id: (json['id'] ?? '').toString(),
      activityId: (json['activityId'] ?? json['activity_id'] ?? '').toString(),
      activityName:
          (json['activityName'] ?? json['activity_name'] ?? 'Activity')
              .toString(),
      completedAt: DateTime.tryParse(
            (json['completedAt'] ?? json['completed_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse((json['duration'] ?? 0).toString()) ?? 0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'activityName': activityName,
      'completedAt': completedAt.toIso8601String(),
      'duration': duration,
      'notes': notes,
    };
  }
}
