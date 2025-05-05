import 'package:flutter/material.dart';

class FloatingActButton extends StatefulWidget {
  const FloatingActButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.minWidth = 120,
    this.elevation = 4,
    this.backgroundColor,
    this.foregroundColor,
    this.hoverColor,
    this.tooltip,
  });

  final String text;
  final VoidCallback onPressed;
  final Icon? icon;
  final double minWidth;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverColor;
  final String? tooltip;

  @override
  State<FloatingActButton> createState() => _FloatingActButtonState();
}

class _FloatingActButtonState extends State<FloatingActButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    isHovered ? _controller.forward() : _controller.reverse();
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
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Tooltip(
          message: widget.tooltip ?? widget.text,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, _isHovered ? -2.0 : 0.0)
                  ..scale(_scaleAnimation.value),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: FloatingActionButton.extended(
              heroTag: null,
              onPressed: widget.onPressed,
              backgroundColor: _isPressed
                  ? widget.hoverColor?.withValues(alpha: 0.9) ??
                      widget.backgroundColor ??
                      colorScheme.primaryContainer
                  : widget.backgroundColor ?? colorScheme.primary,
              foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
              elevation: _isHovered ? widget.elevation * 2 : widget.elevation,
              hoverElevation: widget.elevation * 1.5,
              focusElevation: widget.elevation * 2,
              highlightElevation: widget.elevation * 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              icon: widget.icon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: widget.foregroundColor ?? colorScheme.onPrimary,
                        size: 24,
                      ),
                      child: widget.icon!,
                    )
                  : null,
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.text,
                    key: ValueKey(widget.text),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: widget.foregroundColor ?? colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
