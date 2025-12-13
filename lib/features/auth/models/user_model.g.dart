// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      username: json['username'] as String,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      selfReportedStress: json['selfReportedStress'] as String?,
      gad7Score: (json['gad7Score'] as num?)?.toInt(),
      physicalActivityWeek: (json['physicalActivityWeek'] as num?)?.toInt(),
      importanceStressReduction: json['importanceStressReduction'] as String?,
      primaryGoal: json['primaryGoal'] as String?,
      workoutGoalDays: (json['workoutGoalDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'age': instance.age,
      'gender': instance.gender,
      'height': instance.height,
      'weight': instance.weight,
      'selfReportedStress': instance.selfReportedStress,
      'gad7Score': instance.gad7Score,
      'physicalActivityWeek': instance.physicalActivityWeek,
      'importanceStressReduction': instance.importanceStressReduction,
      'primaryGoal': instance.primaryGoal,
      'workoutGoalDays': instance.workoutGoalDays,
    };
