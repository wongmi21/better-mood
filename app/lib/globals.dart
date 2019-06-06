import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Global {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseUser user;
}