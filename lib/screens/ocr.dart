import 'package:flutter/material.dart';
import 'package:abstractify/screens/handocr.dart';
import 'package:abstractify/screens/typedocr.dart';
import 'package:abstractify/models/squareoutlinedbutton.dart';

class Ocr extends StatelessWidget {
  const Ocr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SquareOutlinedButton(
                size: 150,
                text: "Typed",
                func: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const TypedOcr(),
                    ),
                  );
                },
              ),
              SquareOutlinedButton(
                size: 150,
                text: "Handwritten",
                func: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const HandOcr(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
