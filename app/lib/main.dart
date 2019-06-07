import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'events_page.dart';
import 'meds_page.dart';
import 'mood_page.dart';

void main() async {
  bool inDebugMode = false;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (inDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  await FlutterCrashlytics().initialize();
  runZoned<Future<Null>>(() async {
    runApp(BetterMood());
  }, onError: (error, stackTrace) async {
    await FlutterCrashlytics().reportCrash(
      error,
      stackTrace,
      forceCrash: false,
    );
  });
}

class BetterMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  final pages = [EventsPage(), MedsPage(), MoodPage()];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
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
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
