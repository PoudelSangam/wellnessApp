import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final String programTitle;
  final String duration;
  final List<String> exercises;
  final String programType;
  final Color color;
  final int? activityId;

  const WorkoutTimerScreen({
    super.key,
    required this.programTitle,
    required this.duration,
    required this.exercises,
    required this.programType,
    required this.color,
    this.activityId,
  });

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  int _totalSeconds = 0;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _currentExerciseIndex = 0;
  bool _isCompleted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _parseDuration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _parseDuration() {
    // Parse duration like "35-45 minutes" or "20-25 minutes"
    final match = RegExp(r'(\d+)').firstMatch(widget.duration);
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      _totalSeconds = minutes * 60;
    } else {
      _totalSeconds = 30 * 60; // Default 30 minutes
    }
  }

  void _startTimer() {
    if (_isCompleted) return;
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds >= _totalSeconds) {
        _completeWorkout();
      } else {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _isRunning = false;
      _isPaused = false;
      _currentExerciseIndex = 0;
      _isCompleted = false;
    });
  }

  Future<void> _submitActivityCompletion(int motivation) async {
    if (widget.activityId == null) {
      Logger.warning('No activity ID provided, skipping API call');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Mark activity as complete
      await _apiService.post(
        '/api/workout/activity/${widget.activityId}/complete/',
        body: {
          'completed': true,
          'motivation': motivation,
        },
      );
      Logger.info('Activity ${widget.activityId} marked as complete');

      // Submit workout feedback
      final completionRate = _totalSeconds > 0 ? (_elapsedSeconds / _totalSeconds) : 1.0;
      await _apiService.post(
        '/api/workout/feedback/',
        body: {
          'engagement_delta': completionRate >= 0.8 ? 0.15 : 0.05,
          'workout_completed': widget.programType == 'physical',
          'meditation_completed': widget.programType == 'mental',
          'feedback_rating': motivation,
          'notes': 'Completed ${widget.programTitle} in ${_formatTime(_elapsedSeconds)}',
        },
      );
      Logger.info('Workout feedback submitted');
    } catch (e) {
      Logger.error('Failed to mark activity as complete: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _completeWorkout() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });

    // Show motivation rating dialog
    int? motivation = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _MotivationDialog(),
    );

    if (motivation == null) return; // User cancelled

    // Submit to API
    await _submitActivityCompletion(motivation);

    if (!mounted) return;

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: widget.color, size: 32),
            const SizedBox(width: 12),
            const Expanded(child: Text('Workout Complete!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congratulations! You completed ${widget.programTitle}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatTime(_elapsedSeconds)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${widget.exercises.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Motivation:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text('$motivation/5'),
                        ],
                      ),
                    ],
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
              if (context.canPop()) {
                context.pop(); // Go back to previous screen
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _elapsedSeconds / _totalSeconds : 0.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.programTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTimer,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Timer Display
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Progress
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(_elapsedSeconds),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: widget.color,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'of ${_formatTime(_totalSeconds)}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isRunning && !_isPaused)
                          ElevatedButton.icon(
                            onPressed: _startTimer,
                            icon: const Icon(Icons.play_arrow, size: 32),
                            label: const Text('Start', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        
                        if (_isRunning)
                          ElevatedButton.icon(
                            onPressed: _pauseTimer,
                            icon: const Icon(Icons.pause, size: 32),
                            label: const Text('Pause', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        
                        if (_isPaused)
                          ElevatedButton.icon(
                            onPressed: _startTimer,
                            icon: const Icon(Icons.play_arrow, size: 32),
                            label: const Text('Resume', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isRunning ? null : _resetTimer,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _completeWorkout,
                          icon: const Icon(Icons.check),
                          label: const Text('Finish Early'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Exercise List
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Exercise',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${_currentExerciseIndex + 1}/${widget.exercises.length}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.exercises[_currentExerciseIndex],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Previous',
                        ),
                        Text(
                          'Exercise ${_currentExerciseIndex + 1}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          onPressed: _currentExerciseIndex < widget.exercises.length - 1
                              ? _nextExercise
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Next',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Motivation Rating Dialog
class _MotivationDialog extends StatefulWidget {
  const _MotivationDialog();

  @override
  State<_MotivationDialog> createState() => _MotivationDialogState();
}

class _MotivationDialogState extends State<_MotivationDialog> {
  int _selectedMotivation = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How motivated did you feel?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Rate your motivation level during this workout'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMotivation = rating;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: rating <= _selectedMotivation
                        ? Colors.red
                        : Colors.grey[300],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            _getMotivationText(_selectedMotivation),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getMotivationColor(_selectedMotivation),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedMotivation),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String _getMotivationText(int level) {
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return '';
    }
  }

  Color _getMotivationColor(int level) {
    if (level <= 2) return Colors.red;
    if (level == 3) return Colors.orange;
    return Colors.green;
  }
}