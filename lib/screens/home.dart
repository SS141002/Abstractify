import 'package:flutter/material.dart';
import 'package:abstractify/models/floatingactbutton.dart';
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
              size: 200,
              icn: Icon(Icons.summarize),
              func: () {
                Navigator.of(context).pushNamed('/summary');
              },
            ),
            FloatingActButton(
              text: "Grammar Checker",
              size: 200,
              icn: Icon(Icons.spellcheck),
              func: () {
                Navigator.of(context).pushNamed('/grammar');
              },
            ),
            FloatingActButton(
              text: "OCR",
              size: 200,
              icn: Icon(Icons.text_snippet),
              func: () {
                Navigator.of(context).pushNamed('/ocr');
              },
            ),
          ],
        ),
      ),
    );
  }
}
