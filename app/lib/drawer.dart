import 'package:flutter/material.dart';

class BetterMoodDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: null,
              decoration:
                  new BoxDecoration(color: Theme.of(context).accentColor),
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
            ])
          ],
        ),
      ),
    );
  }
}
