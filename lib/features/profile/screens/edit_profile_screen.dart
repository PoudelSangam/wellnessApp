import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/custom_button.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _physicalActivityController = TextEditingController();
  final _workoutGoalDaysController = TextEditingController();

  String? _selectedGender;
  String? _selfReportedStress;
  String? _importanceStressReduction;
  String? _primaryGoal;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _ageController.text = user.age?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
      _weightController.text = user.weight?.toString() ?? '';
      _physicalActivityController.text = user.physicalActivityWeek?.toString() ?? '';
      _workoutGoalDaysController.text = user.workoutGoalDays?.toString() ?? '';
      _selectedGender = user.gender;
      _selfReportedStress = user.selfReportedStress;
      _importanceStressReduction = user.importanceStressReduction;
      _primaryGoal = user.primaryGoal;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _physicalActivityController.dispose();
    _workoutGoalDaysController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'age': int.tryParse(_ageController.text),
        'gender': _selectedGender,
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'self_reported_stress': _selfReportedStress,
        'physical_activity_week': int.tryParse(_physicalActivityController.text),
        'importance_stress_reduction': _importanceStressReduction,
        'primary_goal': _primaryGoal,
        'workout_goal_days': int.tryParse(_workoutGoalDaysController.text),
      };

      final profileProvider = context.read<ProfileProvider>();
      final success = await profileProvider.updateProfile(userData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileProvider.errorMessage ?? 'Failed to update profile',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _ageController,
                label: 'Age',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person),
                ),
                items: ['Male', 'Female', 'Other', 'Prefer not to say']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => Validators.validateRequired(value, 'Gender'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _heightController,
                label: 'Height (cm)',
                prefixIcon: Icons.height,
                keyboardType: TextInputType.number,
                validator: Validators.validateHeight,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                prefixIcon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                validator: Validators.validateWeight,
              ),

              const SizedBox(height: 32),

              Text(
                'Wellness Goals',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selfReportedStress,
                decoration: const InputDecoration(
                  labelText: 'Stress Level',
                  prefixIcon: Icon(Icons.psychology_outlined),
                ),
                items: AppConstants.stressLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selfReportedStress = value;
                  });
                },
                validator: (value) =>
                    Validators.validateRequired(value, 'Stress level'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _physicalActivityController,
                label: 'Physical Activity Days/Week',
                prefixIcon: Icons.fitness_center,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final error = Validators.validateNumber(value, 'Physical activity');
                  if (error != null) return error;
                  final days = int.parse(value!);
                  if (days < 0 || days > 7) {
                    return 'Days must be between 0 and 7';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _importanceStressReduction,
                decoration: const InputDecoration(
                  labelText: 'Importance of Stress Reduction',
                  prefixIcon: Icon(Icons.trending_down),
                ),
                items: ['Low', 'Medium', 'High', 'Very High']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _importanceStressReduction = value;
                  });
                },
                validator: (value) =>
                    Validators.validateRequired(value, 'Importance'),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _primaryGoal,
                decoration: const InputDecoration(
                  labelText: 'Primary Goal',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: AppConstants.primaryGoals
                    .map((goal) => DropdownMenuItem(
                          value: goal,
                          child: Text(goal),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _primaryGoal = value;
                  });
                },
                validator: (value) =>
                    Validators.validateRequired(value, 'Primary goal'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _workoutGoalDaysController,
                label: 'Workout Goal Days/Week',
                prefixIcon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final error = Validators.validateNumber(value, 'Workout goal days');
                  if (error != null) return error;
                  final days = int.parse(value!);
                  if (days < 0 || days > 7) {
                    return 'Days must be between 0 and 7';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              Consumer<ProfileProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    onPressed: provider.isLoading ? null : _handleSave,
                    isLoading: provider.isLoading,
                    text: 'Save Changes',
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
