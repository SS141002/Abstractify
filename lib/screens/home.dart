import 'package:flutter/material.dart';
import 'package:abstractify/widgets/floatingactbutton.dart';
import 'package:abstractify/screens/navdrawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Abstractify",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: NavDrawer(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActButton(
              text: "Summarizer",
              minWidth: 200,
              icon: Icon(Icons.summarize),
              onPressed: () {
                Navigator.of(context).pushNamed('/summary');
              },
            ),
            FloatingActButton(
              text: "Grammar Checker",
              minWidth: 200,
              icon: Icon(Icons.spellcheck),
              onPressed: () {
                Navigator.of(context).pushNamed('/grammar');
              },
            ),
            FloatingActButton(
              text: "OCR",
              minWidth: 200,
              icon: Icon(Icons.text_snippet),
              onPressed: () {
                Navigator.of(context).pushNamed('/ocr');
              },
            ),
          ],
        ),
      ),
    );
  }
}