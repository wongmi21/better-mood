import 'package:flutter/material.dart';
import 'globals.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Text('Welcome ${Global.user.displayName ?? 'Guest'}'),
    );
  }
}
