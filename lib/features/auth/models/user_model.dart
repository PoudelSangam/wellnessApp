import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String? id;
  final String email;
  final String username;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? selfReportedStress;
  final int? gad7Score;
  final int? physicalActivityWeek;
  final String? importanceStressReduction;
  final String? primaryGoal;
  final int? workoutGoalDays;
  
  UserModel({
    this.id,
    required this.email,
    required this.username,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.selfReportedStress,
    this.gad7Score,
    this.physicalActivityWeek,
    this.importanceStressReduction,
    this.primaryGoal,
    this.workoutGoalDays,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? selfReportedStress,
    int? gad7Score,
    int? physicalActivityWeek,
    String? importanceStressReduction,
    String? primaryGoal,
    int? workoutGoalDays,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      selfReportedStress: selfReportedStress ?? this.selfReportedStress,
      gad7Score: gad7Score ?? this.gad7Score,
      physicalActivityWeek: physicalActivityWeek ?? this.physicalActivityWeek,
      importanceStressReduction: importanceStressReduction ?? this.importanceStressReduction,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      workoutGoalDays: workoutGoalDays ?? this.workoutGoalDays,
    );
  }
}
