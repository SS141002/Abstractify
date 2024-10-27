import 'package:flutter/material.dart';

class SquareOutlinedButton extends StatelessWidget {
  const SquareOutlinedButton({
    super.key,
    required this.text,
    required this.func,
    required this.size,
  });

  final String text;
  final double size;
  final void Function() func;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          width: 1.5,
          color: (Theme.of(context).brightness == Brightness.light)
              ? Colors.black
              : Colors.white,
        ),
      ),
      onPressed: func,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
