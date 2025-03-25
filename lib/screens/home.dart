import 'package:flutter/material.dart';
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple, // Change app bar color
      ),
      drawer: NavDrawer(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FeatureCard(
                title: "Summarizer",
                imagePath: "assets/images/summarizer.png",
                icon: Icons.summarize,
                route: '/summary',
              ),
              SizedBox(height: 20),
              FeatureCard(
                title: "Grammar Checker",
                imagePath: "assets/images/grammar.png",
                icon: Icons.spellcheck,
                route: '/grammar',
              ),
              SizedBox(height: 20),
              FeatureCard(
                title: "OCR",
                imagePath: "assets/images/ocr.png",
                icon: Icons.text_snippet,
                route: '/ocr',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final IconData icon;
  final String route;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.icon,
    required this.route,
  }) : super(key: key);

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.85; // Shrink effect
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Restore size
    });
    Future.delayed(Duration(milliseconds: 50), () {
      Navigator.of(context).pushNamed(widget.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_scale),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 250,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(widget.imagePath, height: 80),
                SizedBox(height: 10),
                Icon(widget.icon, size: 40, color: Colors.deepPurple),
                SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
