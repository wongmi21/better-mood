import 'dart:async';

import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'chat_page.dart';
import 'events_page.dart';
import 'globals.dart';
import 'login_page.dart';
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
    runApp(App());
  }, onError: (error, stackTrace) async {
    await FlutterCrashlytics().reportCrash(
      error,
      stackTrace,
      forceCrash: false,
    );
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      routes: {
        '/': (_) => LoginPage(),
        '/events': (_) => EventsPage(),
        '/meds': (_) => MedsPage(),
        '/mood': (_) => MoodPage(),
        '/chat': (_) => ChatPage(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: Global.analytics),
      ],
    );
  }
}
