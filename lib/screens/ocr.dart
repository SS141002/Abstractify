import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/models/floatingactbutton.dart';

class Ocr extends StatelessWidget {
  const Ocr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OCR",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActButton(
                text: "Typed",
                size: 150,
                func: () {
                  Navigator.of(context).pushNamed('/ocr/typed');
                },
                icn: Icon(Icons.keyboard),
              ),
              FloatingActButton(
                text: "Handwritten",
                size: 150,
                func: () {
                  Navigator.of(context).pushNamed('/ocr/hand');
                },
                icn: Icon(Icons.draw),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
