import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _AnimatedGradientBlobs()),
        const Positioned.fill(child: _AnimatedSparkles()),
        Positioned.fill(
          child: Container(
            color: Colors.black
                .withValues(alpha: 0.05), // slight overlay for contrast
          ),
        ),
        child,
      ],
    );
  }
}

// 🌈 Animated gradient blobs
class _AnimatedGradientBlobs extends StatefulWidget {
  const _AnimatedGradientBlobs();

  @override
  State<_AnimatedGradientBlobs> createState() => _AnimatedGradientBlobsState();
}

class _AnimatedGradientBlobsState extends State<_AnimatedGradientBlobs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            _blob(
              offset: Offset(100 + sin(_controller.value * pi) * 50, 100),
              color: Colors.purple.withValues(alpha: 0.25),
              size: 200,
            ),
            _blob(
              offset: Offset(300 + cos(_controller.value * pi) * 80, 400),
              color: Colors.blue.withValues(alpha: 0.2),
              size: 180,
            ),
            _blob(
              offset: Offset(200, 250 + sin(_controller.value * 2 * pi) * 60),
              color: Colors.tealAccent.withValues(alpha: 0.2),
              size: 220,
            ),
          ],
        );
      },
    );
  }

  Widget _blob({
    required Offset offset,
    required Color color,
    required double size,
  }) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: const SizedBox(),
        ),
      ),
    );
  }
}

// ✨ Sparkle particles
class _AnimatedSparkles extends StatefulWidget {
  const _AnimatedSparkles();

  @override
  State<_AnimatedSparkles> createState() => _AnimatedSparklesState();
}

class _AnimatedSparklesState extends State<_AnimatedSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _SparklePainter(_controller.value),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  _SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.07);

    for (int i = 0; i < 80; i++) {
      final dx = (i * 53 + progress * 1000) % size.width;
      final dy = (i * 29 + progress * 800) % size.height;
      final radius = 1.0 + sin(progress * 2 * pi + i) * 1.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}
