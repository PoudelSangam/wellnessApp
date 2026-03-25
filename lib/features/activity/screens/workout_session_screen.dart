import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/activity_model.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final ActivityModel? activity;
  final bool autoStart;
  final List<ExerciseStep>? exercisesList; // Direct list of exercises from API
  final int? programId; // ID of the program for feedback API

  const WorkoutSessionScreen({
    super.key,
    this.activity,
    this.autoStart = true,
    this.exercisesList,
    this.programId,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _exerciseRemainingSeconds = 0;
  int _getReadySeconds = 5;
  Timer? _timer;
  bool _isPaused = false;
  bool _isWorkoutStarted = false;
  bool _isExerciseActive = false;
  bool _isGetReady = false;
  bool _allowPopWithoutPrompt = false;
  
  List<ExerciseStep> _exercises = [];

  @override
  void initState() {
    super.initState();
    _initializeExercises();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isWorkoutStarted) {
          _startWorkout();
        }
      });
    }
  }

  void _initializeExercises() {
    // If exercises are provided directly (from API), use them
    if (widget.exercisesList != null && widget.exercisesList!.isNotEmpty) {
      _exercises = widget.exercisesList!;
      return;
    }

    // Otherwise, create exercise steps from the activity
    if (widget.activity == null) {
      return;
    }

    final instructions = widget.activity!.instructions ?? [];
    final totalDurationSeconds =
        widget.activity!.durationSeconds ?? (widget.activity!.duration * 60);
    
    if (instructions.isNotEmpty && instructions.length > 1) {
      // If we have multiple instructions, create exercises from them
      final durationPerExercise =
          (totalDurationSeconds / instructions.length).ceil();
      _exercises = instructions.asMap().entries.map((entry) {
        return ExerciseStep(
          name: instructions[entry.key].split('.').first.trim(),
          description: entry.value,
          duration: durationPerExercise,
        );
      }).toList();
    } else {
      // Create exercises based on activity duration (more realistic exercise breakdown)
      // Each exercise is roughly 60 seconds, creating many exercises for longer workouts
      final exerciseDurationSeconds = 60; // 1 minute per exercise
      final numberOfExercises = (totalDurationSeconds / exerciseDurationSeconds).ceil().clamp(5, 100);
      final actualDurationPerExercise = (totalDurationSeconds / numberOfExercises).ceil();
      
      _exercises = List.generate(numberOfExercises, (index) {
        return ExerciseStep(
          name: '${widget.activity!.name} - Exercise ${index + 1}',
          description: widget.activity!.description,
          duration: actualDurationPerExercise,
        );
      });
    }
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
      _currentExerciseIndex = 0;
    });
    _startNextExercise();
  }

  void _startNextExercise() {
    if (_currentExerciseIndex >= _exercises.length) {
      // All exercises completed
      _completeWorkout();
      return;
    }

    final currentExercise = _exercises[_currentExerciseIndex];
    setState(() {
      _isExerciseActive = true;
      _exerciseRemainingSeconds = currentExercise.duration;
    });
    _startExerciseTimer();
  }

  void _startExerciseTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_exerciseRemainingSeconds > 0) {
            _exerciseRemainingSeconds--;
          } else {
            // Current exercise finished
            _timer?.cancel();
            _finishCurrentExercise();
          }
        });
      }
    });
  }

  void _finishCurrentExercise() {
    // Call API to mark exercise as complete if it has an ID
    final currentExercise = _exercises[_currentExerciseIndex];
    if (currentExercise.id != null) {
      final activityProvider = context.read<ActivityProvider>();
      activityProvider.completeExercise(currentExercise.id!);
    }

    // Move to next exercise and start get ready countdown
    setState(() {
      _currentExerciseIndex++;
      _isExerciseActive = false;
      _isGetReady = true;
      _getReadySeconds = 5;
    });
    
    // Start countdown
    _startGetReadyCountdown();
  }

  void _startGetReadyCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _getReadySeconds--;
      });
      
      if (_getReadySeconds <= 0) {
        _timer?.cancel();
        setState(() {
          _isGetReady = false;
        });
        if (mounted) {
          _startNextExercise();
        }
      }
    });
  }

  void _resetWorkout() {
    _timer?.cancel();
    setState(() {
      _currentExerciseIndex = 0;
      _exerciseRemainingSeconds = 0;
      _isPaused = false;
      _isWorkoutStarted = false;
      _isExerciseActive = false;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _leaveSessionToHome({bool forceHome = false}) async {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    // Programmatic pop should bypass onWillPop confirmation.
    _allowPopWithoutPrompt = true;

    final router = GoRouter.of(context);

    // This screen is opened with Navigator.push, so close it directly.
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }

    if (!mounted) {
      return;
    }

    if (forceHome || _isWorkoutStarted) {
      router.go('/home');
    }
  }

  Future<void> _confirmExitWorkout() async {
    if (!mounted) {
      return;
    }

    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Exit Workout Session?'),
            content: const Text(
              'Are you sure you want to exit workout session?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldExit || !mounted) {
      return;
    }

    _timer?.cancel();

    // This page is opened via Navigator.push. Close it first, then force Home tab.
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    _allowPopWithoutPrompt = true;
    if (navigator.canPop()) {
      navigator.pop();
    }
    router.go('/home');
  }

  Future<void> _completeWorkout() async {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    // Show motivation rating dialog
    _showMotivationRatingDialog();
  }

  void _showMotivationRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('How motivated did you feel?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Rate your motivation level from 1 to 5',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _submitFeedback(index + 1);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(int motivation) async {
    try {
      if (widget.programId != null) {
        final activityProvider = context.read<ActivityProvider>();
        await activityProvider.submitWorkoutFeedback(
          widget.programId!,
          motivation,
        );
      }

      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.successColor, size: 32),
            SizedBox(width: 12),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Amazing work! You\'ve completed the workout. 🎉',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.activity != null
                        ? '${widget.activity!.duration} minutes'
                        : '${_exercises.fold<int>(0, (sum, ex) => sum + ex.duration) ~/ 60} minutes',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _leaveSessionToHome(forceHome: true);
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_allowPopWithoutPrompt) {
          return true;
        }
        await _confirmExitWorkout();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.activity?.name ?? 'Workout Session'),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Home',
              onPressed: () => _leaveSessionToHome(forceHome: true),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _confirmExitWorkout();
            },
          ),
        ),
        body: !_isWorkoutStarted ? _buildStartScreen() : _buildWorkoutScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Total Duration Timer
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 8,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_exercises.fold<int>(0, (sum, ex) => sum + ex.duration)),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'total workout time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Start Button
          ElevatedButton.icon(
            onPressed: _startWorkout,
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text(
              'Start',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Reset Button
          OutlinedButton.icon(
            onPressed: _resetWorkout,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 30),

          // All Exercises List
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout Exercises (Sequential)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Exercises List
                ...List.generate(_exercises.length, (index) {
                  final exercise = _exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatTime(exercise.duration),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            Text(
                              exercise.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWorkoutScreen() {
    final currentExercise = _currentExerciseIndex < _exercises.length 
        ? _exercises[_currentExerciseIndex] 
        : null;
    
    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: _currentExerciseIndex / _exercises.length,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
          minHeight: 6,
        ),
        
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Current Exercise Number
                Text(
                  'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Current Exercise Timer (if active)
                if (_isExerciseActive && currentExercise != null)
                  Column(
                    children: [
                      Text(
                        currentExercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      
                      // Exercise Timer Circle
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.secondaryColor,
                            width: 8,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_exerciseRemainingSeconds),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              const Text(
                                'EXERCISE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Show exercise steps if available from API data
                      if (currentExercise.instructions != null && currentExercise.instructions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Exercise Steps:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...currentExercise.instructions!.asMap().entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else if (_isGetReady && _currentExerciseIndex < _exercises.length)
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Get Ready for Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$_getReadySeconds',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentExercise!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
                
                // Upcoming Exercises
                if (_currentExerciseIndex < _exercises.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming Exercises',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          (_exercises.length - _currentExerciseIndex - 1).clamp(0, 3),
                          (index) {
                            final exerciseIndex = _currentExerciseIndex + 1 + index;
                            final exercise = _exercises[exerciseIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${exerciseIndex + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(exercise.duration),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        
        // Control Buttons - Outside ScrollView
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isExerciseActive ? _togglePause : null,
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(_isPaused ? 'Resume' : 'Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _confirmExitWorkout();
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Exit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExerciseStep {
  final int? id;
  final String name;
  final String description;
  final int duration;
  final List<String>? instructions;

  ExerciseStep({
    this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.instructions,
  });
}
