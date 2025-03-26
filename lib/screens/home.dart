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
                route: '/summary',
              ),
              SizedBox(height: 20),
              FeatureCard(
                title: "Grammar Checker",
                imagePath: "assets/images/grammar.png",
                route: '/grammar',
              ),
              SizedBox(height: 20),
              FeatureCard(
                title: "OCR",
                imagePath: "assets/images/ocr.png",
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
  final String route;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.route,
  }) : super(key: key);

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  double _scale = 1.0; // Default scale
  Color _cardColor = Colors.white; // Default card color

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // Shrink effect on tap
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Restore size after tap
    });

    Future.delayed(Duration(milliseconds: 50), () {
      Navigator.of(context).pushNamed(widget.route);
    });
  }

  void _onHover(bool hovering) {
    setState(() {
      _scale = hovering ? 1.1 : 1.0; // Grow effect from center
      _cardColor = hovering ? Colors.deepPurple.withOpacity(0.2) : Colors.white; // Change color
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(_scale, _scale, 1), // Grows from center
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: _cardColor, // Dynamic background color
            boxShadow: [
              if (_scale > 1.0) // Only apply shadow when hovered
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
            ],
          ),
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
                  Image.asset(widget.imagePath, height: 80), // Feature image
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
      ),
    );
  }
}
