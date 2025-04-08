import 'package:flutter/material.dart';
import 'dart:ui';
class CarouselCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final bool isActive;

  const CarouselCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
    required this.isActive,
  });

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.route.isNotEmpty
          ? Navigator.pushNamed(context, widget.route)
          : null,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon,
                      size: 40,
                      color: Colors.white.withOpacity(widget.isActive ? 1 : 0.7)),
                  const SizedBox(height: 15),
                  Text(widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(widget.isActive ? 1 : 0.7),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}