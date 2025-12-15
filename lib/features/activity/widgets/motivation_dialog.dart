import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MotivationDialog extends StatefulWidget {
  final Function(int motivation) onComplete;

  const MotivationDialog({
    super.key,
    required this.onComplete,
  });

  @override
  State<MotivationDialog> createState() => _MotivationDialogState();
}

class _MotivationDialogState extends State<MotivationDialog> {
  int _selectedMotivation = 3;

  final List<String> _motivationLabels = [
    'Very Low',
    'Low',
    'Moderate',
    'Good',
    'High',
    'Very High',
  ];

  final List<IconData> _motivationIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
    Icons.celebration,
  ];

  final List<Color> _motivationColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow[700]!,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _motivationColors[_selectedMotivation].withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'How motivated did you feel?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Motivation Icon Display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _motivationIcons[_selectedMotivation],
                key: ValueKey(_selectedMotivation),
                size: 80,
                color: _motivationColors[_selectedMotivation],
              ),
            ),

            const SizedBox(height: 16),

            // Motivation Label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _motivationLabels[_selectedMotivation],
                key: ValueKey(_selectedMotivation),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _motivationColors[_selectedMotivation],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Level $_selectedMotivation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _motivationColors[_selectedMotivation],
                inactiveTrackColor: _motivationColors[_selectedMotivation].withOpacity(0.2),
                thumbColor: _motivationColors[_selectedMotivation],
                overlayColor: _motivationColors[_selectedMotivation].withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                trackHeight: 6,
              ),
              child: Slider(
                value: _selectedMotivation.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (value) {
                  setState(() {
                    _selectedMotivation = value.toInt();
                  });
                },
              ),
            ),

            // Level Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _selectedMotivation == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedMotivation == index
                          ? _motivationColors[index]
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onComplete(_selectedMotivation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _motivationColors[_selectedMotivation],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
