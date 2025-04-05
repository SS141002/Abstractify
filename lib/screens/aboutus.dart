import 'package:flutter/material.dart';
import 'package:abstractify/widgets/aboutcard.dart';
import 'package:abstractify/screens/navdrawer.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
        ),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Team Members",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AboutUsCard(
                  name: "Somya Sharma",
                  link: "https://www.linkedin.com/in/SS141002",
                  avatarImage: "assets/images/man.png",
                ),
                AboutUsCard(
                  name: "Rishabh Bhandari",
                  link:
                      "https://www.linkedin.com/in/rishabh-bhandari-80a67225a",
                  avatarImage: "assets/images/man.png",
                ),
                AboutUsCard(
                  name: "Varun Kumar Singh",
                  link:
                      "https://www.linkedin.com/in/varun-kumar-singh-2531b6238",
                  avatarImage: "assets/images/man.png",
                ),
                AboutUsCard(
                  name: "Rachit Soni",
                  link: "https://www.linkedin.com/in/rachit-soni-b7764b297",
                  avatarImage: "assets/images/man.png",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
