import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../models/activity_model.dart';
import '../widgets/exercise_animation_widget.dart';
import '../widgets/motivation_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final ActivityModel activity;

  const WorkoutSessionScreen({
    super.key,
    required this.activity,
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
  bool _isResting = false;
  bool _isStarted = false;
  final int _restDuration = 10; // 10 seconds rest between exercises
  
  List<ExerciseStep> _exercises = [];

  @override
  void initState() {
    super.initState();
    _initializeExercises();
  }

  void _initializeExercises() {
    // Create exercise steps from the activity
    final instructions = widget.activity.instructions ?? [];
    
    if (instructions.isNotEmpty && instructions.length > 1) {
      // If we have multiple instructions, create exercises from them
      final durationPerExercise = (widget.activity.duration * 60 / instructions.length).ceil();
      _exercises = instructions.asMap().entries.map((entry) {
        return ExerciseStep(
          name: instructions[entry.key].split('.').first.trim(),
          description: entry.value,
          duration: durationPerExercise,
        );
      }).toList();
    } else {
      // Create multiple sets for better workout structure
      final sets = 3;
      final durationPerSet = (widget.activity.duration * 60 / sets).ceil();
      _exercises = List.generate(sets, (index) {
        return ExerciseStep(
          name: '${widget.activity.name} - Set ${index + 1}',
          description: widget.activity.description,
          duration: durationPerSet,
        );
      });
    }
    
    _totalSeconds = widget.activity.duration * 60;
    _remainingSeconds = _totalSeconds;
  }

  void _startWorkout() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = _exercises[_currentExerciseIndex].duration;
      _isResting = false;
    });
    _startTimer();
  }

  void _resetWorkout() {
    _timer?.cancel();
    setState(() {
      _currentExerciseIndex = 0;
      _remainingSeconds = _totalSeconds;
      _isPaused = false;
      _isResting = false;
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
            _totalSeconds--;
          } else {
            _timer?.cancel();
            if (_isResting) {
              _currentExerciseIndex++;
              if (_currentExerciseIndex < _exercises.length) {
                _startExercise();
              } else {
                _completeWorkout();
              }
            } else {
              // Exercise completed, start rest
              if (_currentExerciseIndex < _exercises.length - 1) {
                _startRest();
              } else {
                _completeWorkout();
              }
            }
          }
        });
      }
    });
  }

  void _startExercise() {
    setState(() {
      _remainingSeconds = _exercises[_currentExerciseIndex].duration;
      _isResting = false;
    });
    _startTimer();
  }

  void _startRest() {
    setState(() {
      _remainingSeconds = _restDuration;
      _isResting = true;
    });
    _startTimer();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentExerciseIndex--;
        _startExercise();
      });
    }
  }

  void _nextExercise() {
    _timer?.cancel();
    setState(() {
      _currentExerciseIndex++;
      if (_currentExerciseIndex < _exercises.length) {
        _startExercise();
      } else {
        _completeWorkout();
      }
    });
  }

  Future<void> _completeWorkout() async {
    _timer?.cancel();
    
    if (mounted) {
      // Show motivation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MotivationDialog(
          onComplete: (motivation) async {
            // Try to parse activity ID as int for the new API
            int? activityId = int.tryParse(widget.activity.id);
            
            if (activityId != null) {
              final activityProvider = context.read<ActivityProvider>();
              final success = await activityProvider.completeActivityWithMotivation(
                activityId,
                motivation,
              );

              if (mounted) {
                if (success) {
                  _showCompletionDialog(motivation);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        activityProvider.errorMessage ?? 'Failed to complete activity',
                      ),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            } else {
              // Fallback to old API if ID is not an integer
              final activityProvider = context.read<ActivityProvider>();
              final success = await activityProvider.completeActivity(widget.activity.id);
              
              if (mounted && success) {
                _showCompletionDialog(motivation);
              }
            }
          },
        ),
      );
    }
  }

  void _showCompletionDialog(int motivation) {
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Motivation Level: $motivation',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to activity detail
            },
            child: const Text('Done'),
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
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit workout screen
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isStarted) {
                _exitWorkout();
              } else {
                Navigator.of(context).pop();
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
                    style: TextStyle(
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => MotivationDialog(
                      onComplete: (motivation) async {
                        int? activityId = int.tryParse(widget.activity.id);
                        
                        if (activityId != null) {
                          final provider = context.read<ActivityProvider>();
                          await provider.completeActivityWithMotivation(activityId, motivation);
                        } else {
                          final provider = context.read<ActivityProvider>();
                          await provider.completeActivity(widget.activity.id);
                        }
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Activity completed! 🎉'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
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
                
                // Exercises List with Animations
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
                            
                            // Exercise Animation Preview
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExerciseAnimationWidget(
                                exerciseName: widget.activity.name,
                                category: widget.activity.category,
                                duration: exercise.duration,
                                autoPlay: false,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            Text(
                              exercise.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        : _exercises.last;

    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentExerciseIndex + 1) / _exercises.length,
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
                      color: _isResting ? Colors.orange : AppTheme.primaryColor,
                      width: 8,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _isResting ? Colors.orange : AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          _isResting ? 'REST' : 'GO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isResting ? Colors.orange : AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Current Exercise Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Exercise',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_currentExerciseIndex + 1}/${_exercises.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isResting ? 'Take a Rest' : currentExercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Arrows
                if (!_isResting)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 32,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 40),
                      Text(
                        'Exercise ${_currentExerciseIndex + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: _currentExerciseIndex < _exercises.length - 1
                            ? _nextExercise
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        iconSize: 32,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Animation Widget
                if (!_isResting)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ExerciseAnimationWidget(
                      exerciseName: widget.activity.name,
                      category: widget.activity.category,
                      duration: currentExercise.duration,
                      autoPlay: !_isPaused,
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(40),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.free_breakfast,
                          size: 100,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Relax and breathe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Exercise Description
                if (!_isResting)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      currentExercise.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

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
