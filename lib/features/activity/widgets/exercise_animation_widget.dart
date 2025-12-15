import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExerciseAnimationWidget extends StatefulWidget {
  final String exerciseName;
  final String category;
  final int duration;
  final bool autoPlay;

  const ExerciseAnimationWidget({
    super.key,
    required this.exerciseName,
    required this.category,
    this.duration = 30,
    this.autoPlay = false,
  });

  @override
  State<ExerciseAnimationWidget> createState() =>
      _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Auto-play if enabled
    if (widget.autoPlay) {
      _isPlaying = true;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise Demo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _toggleAnimation,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Center(
                child: _buildExerciseAnimation(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.exerciseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${widget.duration} seconds',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseAnimation() {
    final category = widget.category.toLowerCase();
    final exerciseName = widget.exerciseName.toLowerCase();

    // Determine which animation to show based on exercise type
    if (exerciseName.contains('push') || exerciseName.contains('up')) {
      return _buildPushUpAnimation();
    } else if (exerciseName.contains('squat')) {
      return _buildSquatAnimation();
    } else if (exerciseName.contains('plank')) {
      return _buildPlankAnimation();
    } else if (exerciseName.contains('jump')) {
      return _buildJumpingJackAnimation();
    } else if (category.contains('breathing') ||
        exerciseName.contains('breath')) {
      return _buildBreathingAnimation();
    } else if (category.contains('meditation') ||
        exerciseName.contains('meditat')) {
      return _buildMeditationAnimation();
    } else if (category.contains('yoga') || exerciseName.contains('yoga')) {
      return _buildYogaAnimation();
    } else if (exerciseName.contains('run') || exerciseName.contains('jog')) {
      return _buildRunningAnimation();
    } else {
      return _buildGenericExerciseAnimation();
    }
  }

  Widget _buildPushUpAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final yOffset = math.sin(value * math.pi * 2) * 20;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ground line
            Positioned(
              bottom: 40,
              child: Container(
                width: 150,
                height: 3,
                color: Colors.grey[300],
              ),
            ),
            // Person doing push-up
            Transform.translate(
              offset: Offset(0, yOffset),
              child: CustomPaint(
                size: const Size(120, 80),
                painter: PushUpPainter(),
              ),
            ),
            // Instruction text
            Positioned(
              bottom: 10,
              child: Text(
                yOffset < 0 ? 'DOWN' : 'UP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSquatAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final squatDepth = math.sin(value * math.pi * 2) * 0.3 + 0.5;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ground line
            Positioned(
              bottom: 30,
              child: Container(
                width: 150,
                height: 3,
                color: Colors.grey[300],
              ),
            ),
            // Person doing squat
            Transform.scale(
              scaleY: squatDepth,
              child: CustomPaint(
                size: const Size(100, 120),
                painter: SquatPainter(),
              ),
            ),
            // Instruction text
            Positioned(
              bottom: 10,
              child: Text(
                squatDepth < 0.6 ? 'DOWN' : 'UP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlankAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmer = math.sin(_controller.value * math.pi * 4) * 0.1 + 0.9;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ground line
            Positioned(
              bottom: 50,
              child: Container(
                width: 180,
                height: 3,
                color: Colors.grey[300],
              ),
            ),
            // Person in plank position
            Opacity(
              opacity: shimmer,
              child: CustomPaint(
                size: const Size(140, 60),
                painter: PlankPainter(),
              ),
            ),
            // Timer
            Positioned(
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hold Position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJumpingJackAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final phase = (value * 2) % 1;
        final armAngle = phase < 0.5 ? phase * math.pi : (1 - phase) * math.pi;
        final legSpread = phase < 0.5 ? phase * 30 : (1 - phase) * 30;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ground line
            Positioned(
              bottom: 30,
              child: Container(
                width: 150,
                height: 3,
                color: Colors.grey[300],
              ),
            ),
            // Person doing jumping jacks
            CustomPaint(
              size: const Size(100, 130),
              painter: JumpingJackPainter(armAngle: armAngle, legSpread: legSpread),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBreathingAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final breathScale = math.sin(value * math.pi * 2) * 0.3 + 1.0;
        final isInhaling = math.sin(value * math.pi * 2) > 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Breathing circle
            Transform.scale(
              scale: breathScale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
            ),
            // Instruction text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isInhaling ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  isInhaling ? 'Breathe In' : 'Breathe Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeditationAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = math.sin(_controller.value * math.pi * 2) * 0.3 + 0.7;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Meditation glow
            Container(
              width: 150 * glow,
              height: 150 * glow,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Person meditating
            CustomPaint(
              size: const Size(100, 100),
              painter: MeditationPainter(),
            ),
            // Floating particles
            ..._buildFloatingParticles(glow),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles(double glow) {
    return List.generate(5, (index) {
      final angle = (index / 5) * math.pi * 2 + _controller.value * math.pi * 2;
      final radius = 60 + glow * 20;
      return Positioned(
        left: 100 + math.cos(angle) * radius,
        top: 100 + math.sin(angle) * radius,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5 * glow),
          ),
        ),
      );
    });
  }

  Widget _buildYogaAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final bendAngle = math.sin(value * math.pi * 2) * 0.3;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Mat
            Positioned(
              bottom: 30,
              child: Container(
                width: 160,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Person in yoga pose
            Transform.rotate(
              angle: bendAngle,
              child: CustomPaint(
                size: const Size(100, 120),
                painter: YogaPainter(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRunningAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final legPhase = (value * 4) % 1;
        final xOffset = (value * 200) % 200 - 100;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ground line
            Positioned(
              bottom: 40,
              child: Container(
                width: 200,
                height: 3,
                color: Colors.grey[300],
              ),
            ),
            // Person running
            Transform.translate(
              offset: Offset(xOffset, 0),
              child: CustomPaint(
                size: const Size(80, 100),
                painter: RunningPainter(legPhase: legPhase),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenericExerciseAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bounce = math.sin(_controller.value * math.pi * 2) * 20;

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -bounce.abs()),
              child: Icon(
                Icons.fitness_center,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Positioned(
              bottom: 20,
              child: Text(
                'Tap play to start',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom Painters for different exercises

class PushUpPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.4, size.height * 0.15),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.25),
      size.width * 0.1,
      paint,
    );

    // Arms
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.15, size.height * 0.1),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.75, size.height * 0.35, size.width * 0.15, size.height * 0.1),
      paint,
    );

    // Legs
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.3, size.width * 0.3, size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    // Body
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.35, size.width * 0.3, size.height * 0.3),
      paint,
    );

    // Legs
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.65, size.width * 0.15, size.height * 0.25),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.65, size.width * 0.15, size.height * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlankPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // Body (horizontal)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.4, size.width * 0.6, size.height * 0.15),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.35),
      size.width * 0.08,
      paint,
    );

    // Arms
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.55, size.width * 0.1, size.height * 0.15),
      paint,
    );

    // Legs
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.75, size.height * 0.55, size.width * 0.1, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JumpingJackPainter extends CustomPainter {
  final double armAngle;
  final double legSpread;

  JumpingJackPainter({required this.armAngle, required this.legSpread});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.12,
      paint,
    );

    // Body
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.27),
      Offset(size.width * 0.5, size.height * 0.6),
      paint,
    );

    // Arms
    final armLength = size.width * 0.25;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.5 - armLength * math.cos(armAngle), size.height * 0.35 - armLength * math.sin(armAngle)),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.5 + armLength * math.cos(armAngle), size.height * 0.35 - armLength * math.sin(armAngle)),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5 - legSpread, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5 + legSpread, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(JumpingJackPainter oldDelegate) =>
      armAngle != oldDelegate.armAngle || legSpread != oldDelegate.legSpread;
}

class MeditationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.15,
      paint,
    );

    // Body (sitting)
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.6);
    path.lineTo(size.width * 0.35, size.height * 0.75);
    path.lineTo(size.width * 0.65, size.height * 0.75);
    path.lineTo(size.width * 0.65, size.height * 0.6);
    path.close();
    canvas.drawPath(path, paint);

    // Arms (meditation pose)
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.55), size.width * 0.08, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.55), size.width * 0.08, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YogaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.12,
      paint,
    );

    // Body (triangle pose)
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.32);
    path.lineTo(size.width * 0.45, size.height * 0.6);
    path.lineTo(size.width * 0.55, size.height * 0.6);
    path.close();
    canvas.drawPath(path, paint);

    // Extended arm
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.2, size.height * 0.3),
      paint..strokeWidth = 6,
    );

    // Legs
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RunningPainter extends CustomPainter {
  final double legPhase;

  RunningPainter({required this.legPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.fill
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.12,
      paint,
    );

    // Body (leaning forward)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.27),
      Offset(size.width * 0.45, size.height * 0.55),
      paint,
    );

    // Running legs (alternating)
    final leg1Forward = legPhase < 0.5;
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(
        size.width * 0.45 + (leg1Forward ? 15 : -15),
        size.height * 0.85,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(
        size.width * 0.45 + (leg1Forward ? -15 : 15),
        size.height * 0.85,
      ),
      paint,
    );

    // Arms
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.35),
      Offset(size.width * 0.3, size.height * 0.45),
      paint,
    );
  }

  @override
  bool shouldRepaint(RunningPainter oldDelegate) => legPhase != oldDelegate.legPhase;
}
