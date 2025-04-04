import 'package:flutter/material.dart';

class FloatingActButton extends StatefulWidget {
  const FloatingActButton({
    super.key,
    required this.text,
    required this.func,
    this.icn,
    this.size,
  });

  final String text;
  final void Function() func;
  final Icon? icn;
  final double? size;

  @override
  State<FloatingActButton> createState() => _FloatingActButtonState();
}

class _FloatingActButtonState extends State<FloatingActButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: _isHovered
            ? Matrix4.translationValues(0, 0, 2) // Moves button slightly
            : Matrix4.identity(),
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: widget.func,
          label: SizedBox(
            width: widget.size,
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          icon: widget.icn,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Chamfered corners
          ),
          elevation: _isHovered ? 10 : 4, // Increases shadow when hovered
        ),
      ),
    );
  }
}
