// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      duration: (json['duration'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      benefits:
          (json['benefits'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'benefits': instance.benefits,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'instructions': instance.instructions,
    };

CompletedActivity _$CompletedActivityFromJson(Map<String, dynamic> json) =>
    CompletedActivity(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      activityName: json['activityName'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: (json['duration'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CompletedActivityToJson(CompletedActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'activityName': instance.activityName,
      'completedAt': instance.completedAt.toIso8601String(),
      'duration': instance.duration,
      'notes': instance.notes,
    };
