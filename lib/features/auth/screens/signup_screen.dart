import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/step_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Step 1: Email, Username, Password
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Age, Gender
  final _ageController = TextEditingController();
  String? _selectedGender;

  // Step 3: Height, Weight
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Step 4: Stress & Mental Health
  double _stressLevel = 5.0; // 1-10
  double _gad7Score = 0.0; // 0-21
  final _physicalActivityController = TextEditingController();
  double _importanceStressReduction = 3.0; // 1-5
  String? _primaryGoal;
  final _workoutGoalDaysController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _physicalActivityController.dispose();
    _workoutGoalDaysController.dispose();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState!.validate();
        break;
      case 1:
        isValid = _step2FormKey.currentState!.validate();
        break;
      case 2:
        isValid = _step3FormKey.currentState!.validate();
        break;
      case 3:
        isValid = _step4FormKey.currentState!.validate();
        break;
    }

    if (isValid) {
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _handleSignup();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSignup() async {
    // Map primary goal to integer
    int? primaryGoalValue;
    if (_primaryGoal != null) {
      primaryGoalValue = AppConstants.primaryGoals.indexOf(_primaryGoal!);
    }

    final userData = {
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'password2': _confirmPasswordController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _selectedGender?.toLowerCase(),
      'height': double.tryParse(_heightController.text),
      'weight': double.tryParse(_weightController.text),
      'self_reported_stress': _stressLevel.toInt(),
      'gad7_score': _gad7Score.toInt(),
      'physical_activity_week': int.tryParse(_physicalActivityController.text),
      'importance_stress_reduction': _importanceStressReduction.toInt(),
      'primary_goal': primaryGoalValue,
      'workout_goal_days': int.tryParse(_workoutGoalDaysController.text),
    };

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(userData);

    if (mounted) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Account created successfully! Welcome ${_usernameController.text.trim()}!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigate to home
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) context.go('/home');
        });
      } else {
        // Show detailed error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.errorMessage ?? 'Signup failed. Please try again.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () {
                _handleSignup();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/login'),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: StepIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    onPressed: authProvider.isLoading ? null : _nextStep,
                    isLoading: authProvider.isLoading,
                    text: _currentStep == _totalSteps - 1 ? 'Complete Signup' : 'Next',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s start with your account details',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

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
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Details',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _ageController,
              label: 'Age',
              prefixIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              validator: Validators.validateAge,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person),
              ),
              items: ['Male', 'Female']
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
              validator: (value) =>
                  Validators.validateRequired(value, 'Gender'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Physical Information',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Help us personalize your experience',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _heightController,
              label: 'Height (cm)',
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
              validator: Validators.validateHeight,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              prefixIcon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              validator: Validators.validateWeight,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _step4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Wellness Goals',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s understand your wellness journey',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            Text(
              'Stress Level: ${_stressLevel.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _stressLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: _stressLevel.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _stressLevel = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1', style: Theme.of(context).textTheme.bodySmall),
                Text('10', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'GAD-7 Score: ${_gad7Score.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _gad7Score,
              min: 0,
              max: 21,
              divisions: 21,
              label: _gad7Score.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _gad7Score = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.bodySmall),
                Text('21', style: Theme.of(context).textTheme.bodySmall),
              ],
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
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            Text(
              'Importance of Stress Reduction: ${_importanceStressReduction.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _importanceStressReduction,
              min: 1,
              max: 5,
              divisions: 4,
              label: _importanceStressReduction.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _importanceStressReduction = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1', style: Theme.of(context).textTheme.bodySmall),
                Text('5', style: Theme.of(context).textTheme.bodySmall),
              ],
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
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
