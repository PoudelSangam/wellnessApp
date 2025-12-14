import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/workout_timer_screen.dart';

class ProgramCard extends StatefulWidget {
  final String title;
  final String description;
  final List<String> items;
  final String duration;
  final String frequency;
  final String? intensity;
  final String? focus;
  final IconData icon;
  final Color color;
  final String programType; // 'physical' or 'mental'

  const ProgramCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.duration,
    required this.frequency,
    this.intensity,
    this.focus,
    required this.icon,
    required this.color,
    required this.programType,
  });

  @override
  State<ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<ProgramCard> {
  bool _isExpanded = false;
  bool _isCompleted = false;

  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTimerScreen(
          programTitle: widget.title,
          duration: widget.duration,
          exercises: widget.items,
          programType: widget.programType,
          color: widget.color,
        ),
      ),
    );
  }

  void _markAsComplete() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isCompleted ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              _isCompleted 
                  ? '${widget.title} marked as complete!'
                  : '${widget.title} unmarked',
            ),
          ],
        ),
        backgroundColor: _isCompleted ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProgram() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Program'),
        content: Text('Share "${widget.title}" with friends to motivate them!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Program shared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: _isCompleted ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(_isCompleted ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isCompleted ? Colors.grey : widget.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: _isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ),
                          if (_isCompleted)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Items/Activities
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.intensity != null ? 'Exercises' : 'Activities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              ...widget.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: widget.color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                '${widget.items.length} ${widget.intensity != null ? 'exercises' : 'activities'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],

            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    Icons.timer_outlined,
                    'Duration',
                    widget.duration,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    Icons.repeat,
                    'Frequency',
                    widget.frequency,
                  ),
                  if (widget.intensity != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      Icons.trending_up,
                      'Intensity',
                      widget.intensity!,
                    ),
                  ],
                  if (widget.focus != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      Icons.center_focus_strong,
                      'Focus',
                      widget.focus!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCompleted ? null : _startWorkout,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _markAsComplete,
                    icon: Icon(_isCompleted ? Icons.check_circle : Icons.circle_outlined),
                    label: Text(_isCompleted ? 'Completed' : 'Mark Done'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isCompleted ? Colors.green : widget.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: _isCompleted ? Colors.green : widget.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Additional Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _shareProgram,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Program saved to favorites!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, size: 18),
                  label: const Text('Save'),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(widget.title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.description),
                              const SizedBox(height: 16),
                              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...widget.items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• '),
                                        Expanded(child: Text(item)),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
