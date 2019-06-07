import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          title: Text('Events'),
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/meds_icon.png'),
          ),
          title: Text('Medications'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.tag_faces),
          title: Text('Moods'),
        ),
      ],
      onTap: (index) {
        Navigator.of(context).pushReplacementNamed('/meds');
      },
    );
  }
}
