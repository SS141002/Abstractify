import 'package:flutter/material.dart';
import 'package:abstractify/summary.dart';

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
        title: const Text("Abstractify"),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        /*
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          */
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
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
                    style: TextStyle(fontSize: 20),
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
                    "Grammar Checker",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
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
                    style: TextStyle(fontSize: 20),
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
