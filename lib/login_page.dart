import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                width: 275,
              ),
              SizedBox(height: 50),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 11),
                color: Colors.white,
                child: SizedBox(
                  width: 247,
                  height: 40,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/google_logo.png',
                        height: 18,
                      ),
                      SizedBox(width: 24),
                      Text('Sign in with Google'),
                    ],
                  ),
                ),
                onPressed: () {
                  handleSignIn()
                      .then((FirebaseUser user) => print(user))
                      .catchError((e) => print(e));
                },
              ),
              Padding(
                padding: EdgeInsets.all(15),
              ),
              Text('or continue without signing up')
            ],
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> handleSignIn() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        await firebaseAuth.signInWithCredential(credential);

    return user;
  }

  alert(FirebaseUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            content: ListView(
              children: [
                Text(user.toString()),
              ],
            ),
          ),
    );
  }
}
