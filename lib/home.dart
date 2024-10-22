import 'package:flutter/material.dart';
import 'package:abstractify/summary.dart';
import 'package:abstractify/grammar.dart';

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
        /*
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),*/
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
              },
            ),
            ListTile(
              leading: Icon(Icons.groups),
              title: Text("About Us"),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Summary(),
                  ),
                );
              },
              child: const SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Text(
                    "Summarizer",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  /*side: const BorderSide(color: Colors.white),*/
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const Grammar(),
                  ),
                );
              },
              child: const SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Text(
                    "Grammar Checker",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  /*side: const BorderSide(color: Colors.white),*/
                ),
              ),
              onPressed: () {},
              child: const SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Text(
                    "OCR",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
