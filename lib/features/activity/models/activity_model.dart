import 'package:json_annotation/json_annotation.dart';

part 'activity_model.g.dart';

@JsonSerializable()
class ActivityModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final int duration; // in minutes
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
    required this.difficulty,
    required this.benefits,
    this.imageUrl,
    this.videoUrl,
    this.instructions,
  });
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);
}

@JsonSerializable()
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
  
  factory CompletedActivity.fromJson(Map<String, dynamic> json) =>
      _$CompletedActivityFromJson(json);
  
  Map<String, dynamic> toJson() => _$CompletedActivityToJson(this);
}
