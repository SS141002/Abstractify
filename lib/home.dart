import 'package:flutter/material.dart';
import 'package:abstractify/summary.dart';
import 'package:abstractify/grammar.dart';
import 'package:abstractify/settings.dart';
import 'package:abstractify/aboutus.dart';
import 'package:abstractify/ocr.dart';
import 'package:abstractify/models/squareoutlinedbutton.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            SizedBox(
              height: 270,
              child: DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage("assets/images/download.jpg"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Abstractify",
                      style: TextStyle(fontFamily: "Audiowide", fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Setting"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Settings(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.groups),
              title: Text("About Us"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AboutUs(),
                  ),
                );
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SquareOutlinedButton(
              size: 150,
              text: "Summarizer",
              func: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Summary(),
                  ),
                );
              },
            ),
            SquareOutlinedButton(
              size: 150,
              text: "Grammar Checker",
              func: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Grammar(),
                  ),
                );
              },
            ),
            SquareOutlinedButton(
              size: 150,
              text: "OCR",
              func: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Ocr(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
