import 'package:flutter/material.dart';

import './login_page.dart';

main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      routes: {
        '/': (_) => LoginPage(),
      },
    );
  }
}
