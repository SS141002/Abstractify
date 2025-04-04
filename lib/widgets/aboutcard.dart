import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsCard extends StatelessWidget {
  const AboutUsCard({
    super.key,
    required this.name,
    required this.link,
  });

  final String name;
  final String link;

  Future<void> openWebLink(String link) async {
    final Uri uri = Uri.parse(link);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/images/man.png"),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              IconButton(
                icon: Image.asset(
                  "assets/images/linkedin.png",
                  height: 32,
                ),
                onPressed: () => openWebLink(link),
              )
            ],
          ),
        ),
      ),
    );
  }
}
