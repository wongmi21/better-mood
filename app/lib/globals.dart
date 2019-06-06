import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Global {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final Firestore firestore = Firestore.instance;
  static FirebaseUser user;
  static String userId;
}