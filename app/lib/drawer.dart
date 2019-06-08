import 'package:flutter/material.dart';

import 'globals.dart';

class BetterMoodDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: Global.user.photoUrl == null
                  ? null
                  : Image.network(Global.user.photoUrl),
              accountName: Text(
                  Global.user.displayName == null
                      ? 'Guest'
                      : Global.user.displayName,
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
              accountEmail: Global.user.email == null
                  ? null
                  : Text(Global.user.email,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w500)),
            ),
            Column(children: [
              ListTile(
                leading: Icon(Icons.event),
                title: Text(
                  'Events',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/events');
                },
              ),
              ListTile(
                leading: ImageIcon(
                  AssetImage('assets/meds_icon.png'),
                ),
                title: Text(
                  'Medications',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/meds');
                },
              ),
              ListTile(
                leading: Icon(Icons.tag_faces),
                title: Text(
                  'Mood',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/mood');
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text(
                  'Chat',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/chat');
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Global.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}
