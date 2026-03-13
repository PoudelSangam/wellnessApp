import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class _SignupChoice {
  final String label;
  final String value;

  const _SignupChoice({required this.label, required this.value});
}

class _GoalChoice {
  final String label;
  final int value;

  const _GoalChoice({required this.label, required this.value});
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  static const List<_SignupChoice> _genderOptions = [
    _SignupChoice(label: 'Male', value: 'male'),
    _SignupChoice(label: 'Female', value: 'female'),
    _SignupChoice(label: 'Other', value: 'other'),
  ];

  static const List<_SignupChoice> _dietTypeOptions = [
    _SignupChoice(label: 'Vegetarian', value: 'vegetarian'),
    _SignupChoice(label: 'Vegan', value: 'vegan'),
    _SignupChoice(label: 'Balanced', value: 'balanced'),
    _SignupChoice(label: 'Junk Food', value: 'junk food'),
  ];

  static const List<_SignupChoice> _stressLevelOptions = [
    _SignupChoice(label: 'Low', value: 'low'),
    _SignupChoice(label: 'Moderate', value: 'moderate'),
    _SignupChoice(label: 'High', value: 'high'),
  ];

  static const List<_SignupChoice> _mentalHealthOptions = [
    _SignupChoice(label: 'None', value: 'none'),
    _SignupChoice(label: 'Depression', value: 'depression'),
    _SignupChoice(label: 'Anxiety', value: 'anxiety'),
    _SignupChoice(label: 'Bipolar', value: 'bipolar'),
  ];

  static const List<_SignupChoice> _exerciseLevelOptions = [
    _SignupChoice(label: 'Low', value: 'low'),
    _SignupChoice(label: 'Moderate', value: 'moderate'),
    _SignupChoice(label: 'High', value: 'high'),
  ];

  static const List<_GoalChoice> _goalOptions = [
    _GoalChoice(label: 'Improve Fitness', value: 0),
    _GoalChoice(label: 'Increase Mindfulness', value: 1),
    _GoalChoice(label: 'Lose Weight', value: 2),
    _GoalChoice(label: 'Reduce Stress', value: 3),
  ];

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _workHoursController = TextEditingController();
  final _screenTimeController = TextEditingController();
  final _socialInteractionController = TextEditingController();
  final _happinessScoreController = TextEditingController();
  final _workoutGoalDaysController = TextEditingController();

  String? _selectedGender;
  String? _selectedDietType;
  String? _selectedStressLevel;
  String? _selectedMentalHealthCondition;
  String? _selectedExerciseLevel;
  int? _selectedPrimaryGoal;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _sleepHoursController.dispose();
    _workHoursController.dispose();
    _screenTimeController.dispose();
    _socialInteractionController.dispose();
    _happinessScoreController.dispose();
    _workoutGoalDaysController.dispose();
    super.dispose();
  }

  String? _validateIntegerRange(
    String? value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    final error = Validators.validateNumber(value, fieldName);
    if (error != null) return error;

    final parsed = int.tryParse(value!);
    if (parsed == null) {
      return 'Please enter a valid whole number';
    }

    if (min != null && parsed < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && parsed > max) {
      return '$fieldName must be at most $max';
    }

    return null;
  }

  Future<void> _handleSignup() async {
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = {
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'password2': _confirmPasswordController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _selectedGender,
      'diet_type': _selectedDietType,
      'stress_level': _selectedStressLevel,
      'mental_health_condition': _selectedMentalHealthCondition,
      'exercise_level': _selectedExerciseLevel,
      'sleep_hours': int.tryParse(_sleepHoursController.text),
      'work_hours_per_week': int.tryParse(_workHoursController.text),
      'screen_time_per_day': int.tryParse(_screenTimeController.text),
      'self_reported_social_interaction_score':
          int.tryParse(_socialInteractionController.text),
      'happiness_score': int.tryParse(_happinessScoreController.text),
      'primary_goal': _selectedPrimaryGoal,
      'workout_goal_days': int.tryParse(_workoutGoalDaysController.text),
    };

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(userData);

    if (!mounted) {
      return;
    }

    if (success) {
      final isAuthenticated = authProvider.isAuthenticated;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Account created successfully! Welcome ${_usernameController.text.trim()}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: isAuthenticated
              ? null
              : SnackBarAction(
                  label: 'LOGIN',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<AuthProvider>().clearError();
                    context.go('/login');
                  },
                ),
        ),
      );

      if (isAuthenticated) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                authProvider.errorMessage ?? 'Signup failed. Please try again.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _handleSignup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<AuthProvider>().clearError();
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Build your wellness profile',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your account with the updated health and lifestyle details required by the new signup API.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.white.withOpacity(0.92)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Account',
                      subtitle: 'Credentials and identity information.',
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateUsername,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          prefixIcon: Icons.lock_reset_outlined,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _ageController,
                          label: 'Age',
                          prefixIcon: Icons.cake_outlined,
                          validator: (value) =>
                              _validateIntegerRange(value, 'Age', min: 1),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Gender',
                          prefixIcon: Icons.wc_outlined,
                          value: _selectedGender,
                          items: _genderOptions,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Lifestyle',
                      subtitle: 'Daily routines and wellbeing factors.',
                      children: [
                        _buildDropdownField(
                          label: 'Diet Type',
                          prefixIcon: Icons.restaurant_menu_outlined,
                          value: _selectedDietType,
                          items: _dietTypeOptions,
                          onChanged: (value) =>
                              setState(() => _selectedDietType = value),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Stress Level',
                          prefixIcon: Icons.psychology_outlined,
                          value: _selectedStressLevel,
                          items: _stressLevelOptions,
                          onChanged: (value) =>
                              setState(() => _selectedStressLevel = value),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Mental Health Condition',
                          prefixIcon: Icons.favorite_outline,
                          value: _selectedMentalHealthCondition,
                          items: _mentalHealthOptions,
                          onChanged: (value) => setState(
                              () => _selectedMentalHealthCondition = value),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Exercise Level',
                          prefixIcon: Icons.fitness_center_outlined,
                          value: _selectedExerciseLevel,
                          items: _exerciseLevelOptions,
                          onChanged: (value) =>
                              setState(() => _selectedExerciseLevel = value),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _sleepHoursController,
                          label: 'Sleep Hours',
                          prefixIcon: Icons.bedtime_outlined,
                          validator: (value) => _validateIntegerRange(
                              value, 'Sleep hours',
                              min: 0, max: 24),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _workHoursController,
                          label: 'Work Hours Per Week',
                          prefixIcon: Icons.work_outline,
                          validator: (value) => _validateIntegerRange(
                            value,
                            'Work hours per week',
                            min: 0,
                            max: 168,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _screenTimeController,
                          label: 'Screen Time Per Day',
                          prefixIcon: Icons.phone_android_outlined,
                          validator: (value) => _validateIntegerRange(
                            value,
                            'Screen time per day',
                            min: 0,
                            max: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _socialInteractionController,
                          label: 'Social Interaction Score',
                          prefixIcon: Icons.groups_outlined,
                          validator: (value) => _validateIntegerRange(
                            value,
                            'Social interaction score',
                            min: 0,
                            max: 10,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _happinessScoreController,
                          label: 'Happiness Score',
                          prefixIcon: Icons.sentiment_satisfied_alt_outlined,
                          validator: (value) => _validateIntegerRange(
                            value,
                            'Happiness score',
                            min: 0,
                            max: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'Goals',
                      subtitle: 'Tell the app what you want to improve.',
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedPrimaryGoal,
                          decoration: const InputDecoration(
                            labelText: 'Primary Goal',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: _goalOptions
                              .map(
                                (goal) => DropdownMenuItem<int>(
                                  value: goal.value,
                                  child: Text(goal.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPrimaryGoal = value;
                            });
                          },
                          validator: (value) => Validators.validateRequired(
                              value?.toString(), 'Primary goal'),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericField(
                          controller: _workoutGoalDaysController,
                          label: 'Workout Goal Days',
                          prefixIcon: Icons.calendar_month_outlined,
                          validator: (value) => _validateIntegerRange(
                            value,
                            'Workout goal days',
                            min: 0,
                            max: 7,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: authProvider.isLoading ? null : _handleSignup,
                      isLoading: authProvider.isLoading,
                      text: 'Create Account',
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().clearError();
                        context.go('/login');
                      },
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData prefixIcon,
    required String? value,
    required List<_SignupChoice> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) => Validators.validateRequired(selected, label),
    );
  }

  Widget _buildNumericField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.number,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}
