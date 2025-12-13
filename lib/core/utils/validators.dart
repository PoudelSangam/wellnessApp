import '../constants/app_constants.dart';

class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }
  
  // Username Validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
  
  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Number Validation
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  // Age Validation
  static String? validateAge(String? value) {
    final error = validateNumber(value, 'Age');
    if (error != null) return error;
    
    final age = int.parse(value!);
    if (age < 13 || age > 120) {
      return 'Please enter a valid age (13-120)';
    }
    
    return null;
  }
  
  // Height Validation (in cm)
  static String? validateHeight(String? value) {
    final error = validateNumber(value, 'Height');
    if (error != null) return error;
    
    final height = double.parse(value!);
    if (height < 50 || height > 300) {
      return 'Please enter a valid height (50-300 cm)';
    }
    
    return null;
  }
  
  // Weight Validation (in kg)
  static String? validateWeight(String? value) {
    final error = validateNumber(value, 'Weight');
    if (error != null) return error;
    
    final weight = double.parse(value!);
    if (weight < 20 || weight > 500) {
      return 'Please enter a valid weight (20-500 kg)';
    }
    
    return null;
  }
  
  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}
