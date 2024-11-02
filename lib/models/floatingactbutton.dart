import 'package:flutter/material.dart';

class FloatingActButton extends StatelessWidget {
  const FloatingActButton(
      {super.key, required this.text, required this.func, this.icn, this.size});

  final String text;
  final void Function() func;
  final Icon? icn;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: func,
      label: SizedBox(
        width: size,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      icon: icn,
    );
  }
}
