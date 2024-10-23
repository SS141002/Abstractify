import 'package:flutter/material.dart';
import 'package:abstractify/models/squareoutlinedbutton.dart';

class Ocr extends StatelessWidget {
  const Ocr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OCR"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SquareOutlinedButton(
                text: "Typed OCR",
                func: () {},
                size: 150,
              ),
              SquareOutlinedButton(
                text: "Handwritten OCR",
                func: () {},
                size: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
