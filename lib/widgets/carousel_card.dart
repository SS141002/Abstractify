import 'package:flutter/material.dart';
import 'dart:math';

class CarouselCard extends StatefulWidget {
  final String title;
  final String description;
  final String route;
  final IconData icon;

  const CarouselCard({
    super.key,
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.forward();
      _isFront = false;
    } else {
      _controller.reverse();
      _isFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFront(ColorScheme colorScheme, ThemeData theme) {
    return Card(
      elevation: _isHovered ? 10 : 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 150,
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(ColorScheme colorScheme, ThemeData theme) {
    return Card(
      elevation: _isHovered ? 10 : 4,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 150,
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            widget.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(widget.route),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isUnderHalf = _animation.value <= 0.5;
            final angle = _animation.value * pi;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isUnderHalf
                  ? _buildFront(colorScheme, theme)
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: _buildBack(colorScheme, theme),
              ),
            );
          },
        ),
      ),
    );
  }
}
