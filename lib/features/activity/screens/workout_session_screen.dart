import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/activity_model.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/motivation_dialog.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final ActivityModel activity;
  final bool autoStart;

  const WorkoutSessionScreen({
    super.key,
    required this.activity,
    this.autoStart = true,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;
  bool _isStarted = false;
  
  List<ExerciseStep> _exercises = [];

  Future<int?> _askMotivation() async {
    int? selectedMotivation;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MotivationDialog(
        onComplete: (motivation) {
          selectedMotivation = motivation;
        },
      ),
    );
    return selectedMotivation;
  }

  @override
  void initState() {
    super.initState();
    _initializeExercises();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isStarted) {
          _startWorkout();
        }
      });
    }
  }

  void _initializeExercises() {
    // Create exercise steps from the activity
    final instructions = widget.activity.instructions ?? [];
    final totalDurationSeconds =
        widget.activity.durationSeconds ?? (widget.activity.duration * 60);
    
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
      // Create multiple sets for better workout structure
      const sets = 3;
      final durationPerSet = (totalDurationSeconds / sets).ceil();
      _exercises = List.generate(sets, (index) {
        return ExerciseStep(
          name: '${widget.activity.name} - Set ${index + 1}',
          description: widget.activity.description,
          duration: durationPerSet,
        );
      });
    }
    
    _totalSeconds = totalDurationSeconds;
    _remainingSeconds = _totalSeconds;
  }

  void _startWorkout() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = _totalSeconds;
    });
    _startTimer();
  }

  void _resetWorkout() {
    _timer?.cancel();
    setState(() {
      _currentExerciseIndex = 0;
      _remainingSeconds = _totalSeconds;
      _isPaused = false;
      _isStarted = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _completeWorkout();
          }
        });
      }
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

    // Explicit Exit/Home actions should bypass WillPopScope and navigate home.
    if (forceHome || _isStarted) {
      context.go('/home');
      return;
    }

    final popped = await Navigator.of(context).maybePop();
    if (!popped && mounted) {
      context.go('/home');
    }
  }

  Future<void> _completeWorkout() async {
    _timer?.cancel();

    final selectedMotivation = await _askMotivation();
    if (!mounted || selectedMotivation == null) {
      return;
    }

    final activityProvider = context.read<ActivityProvider>();
    final success = await activityProvider.completeWorkoutActivity(
      widget.activity.id,
      motivation: selectedMotivation,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showCompletionDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activityProvider.errorMessage ?? 'Failed to complete activity',
        ),
        backgroundColor: AppTheme.errorColor,
      ),
    );
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
                    '${widget.activity.duration} minutes',
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
              Navigator.of(context).pop(); // Close dialog
              await _leaveSessionToHome(forceHome: true);
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  void _exitWorkout() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text('Are you sure you want to exit? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _leaveSessionToHome(forceHome: true);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Exit'),
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
        if (_isStarted) {
          _exitWorkout();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.activity.name),
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
              if (_isStarted) {
                _exitWorkout();
              } else {
                _leaveSessionToHome();
              }
            },
          ),
        ),
        body: !_isStarted ? _buildStartScreen() : _buildWorkoutScreen(),
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
                    _formatTime(_totalSeconds),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'of ${_formatTime(_totalSeconds)}',
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

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _resetWorkout,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selectedMotivation = await _askMotivation();
                  if (!mounted || selectedMotivation == null) {
                    return;
                  }

                  final provider = context.read<ActivityProvider>();
                  final success = await provider.completeWorkoutActivity(
                    widget.activity.id,
                    motivation: selectedMotivation,
                  );

                  if (!mounted) {
                    return;
                  }

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity marked as done.'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    await _leaveSessionToHome(forceHome: true);
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ?? 'Failed to complete activity',
                      ),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Finish Early'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
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
                      'Workout Exercises',
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
    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: _totalSeconds > 0
              ? (_totalSeconds - _remainingSeconds) / _totalSeconds
              : 0,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
          minHeight: 6,
        ),
        
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Timer Display
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 8,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Text(
                          'TOTAL TIMER',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Instructions
                if (widget.activity.instructions?.isNotEmpty ?? false)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...widget.activity.instructions!.map(
                          (step) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.activity.instructions?.isNotEmpty ?? false)
                  const SizedBox(height: 20),

                const SizedBox(height: 30),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _togglePause,
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
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}





class ExerciseStep {
  final String name;
  final String description;
  final int duration; // in seconds

  ExerciseStep({
    required this.name,
    required this.description,
    required this.duration,
  });
}
