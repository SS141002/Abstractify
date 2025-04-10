import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FluidRainbowBackground extends StatefulWidget {
  final Widget child;

  const FluidRainbowBackground({super.key, required this.child});

  @override
  _FluidRainbowBackgroundState createState() => _FluidRainbowBackgroundState();
}

class _FluidRainbowBackgroundState extends State<FluidRainbowBackground> {
  ui.FragmentShader? _shader;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset('shaders/fluid_rainbow.frag');
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  void _updateMousePosition(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return widget.child;
    }

    return MouseRegion(
      onHover: _updateMousePosition,
      child: CustomPaint(
        painter: _ShaderPainter(shader: _shader!, mousePosition: _mousePosition),
        child: widget.child,
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final Offset mousePosition;

  _ShaderPainter({required this.shader, required this.mousePosition});

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, DateTime.now().millisecondsSinceEpoch / 1000.0)
      ..setFloat(3, mousePosition.dx)
      ..setFloat(4, mousePosition.dy);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
