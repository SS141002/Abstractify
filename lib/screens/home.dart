import 'package:flutter/material.dart';
import 'package:abstractify/screens/navdrawer.dart';
import 'package:abstractify/widgets/carousel_card.dart';

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
          children: const [
            Spacer(),
            Flexible(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 0.75,
                child: CarouselCard(
                  title: "Summarizer",
                  description: "Summarize large texts and documents",
                  route: "/summary",
                  icon: Icons.summarize,
                ),
              ),
            ),
            Spacer(),
            Flexible(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 0.75,
                child: CarouselCard(
                  title: "Grammar Checker",
                  description: "Fix grammar issues with AI",
                  route: "/grammar",
                  icon: Icons.spellcheck,
                ),
              ),
            ),
            Spacer(),
            Flexible(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 0.75,
                child: CarouselCard(
                  title: "OCR",
                  description: "Convert images or handwriting to text",
                  route: "/ocr",
                  icon: Icons.text_snippet,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
