import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.25;
    return Drawer(
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.all(8),
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
            title: Text(" Home"),
            onTap: () {
              String? currentRoute = ModalRoute.of(context)?.settings.name;
              if (currentRoute != '/') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(" Setting"),
            onTap: () {
              Navigator.of(context).popUntil(
                ModalRoute.withName(
                  '/',
                ),
              );
              Navigator.of(context).pushNamed('/setting');
            },
          ),
          ListTile(
            leading: Icon(Icons.groups),
            title: Text(" About Us"),
            onTap: () {
              Navigator.of(context).popUntil(
                ModalRoute.withName(
                  '/',
                ),
              );
              Navigator.of(context).pushNamed('/aboutus');
            },
          )
        ],
      ),
    );
  }
}
