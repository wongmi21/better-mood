import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'globals.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: LinearProgressIndicator(value: _isLoading ? null : 0),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', fit: BoxFit.contain, width: 275),
              SizedBox(height: 50),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 11),
                color: Color(0xFF4267B2),
                child: SizedBox(
                  width: 247,
                  height: 40,
                  child: Row(
                    children: [
                      Image.asset('assets/facebook_logo.png', height: 18),
                      SizedBox(width: 24),
                      Text(
                        'Continue with Facebooa k',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onPressed: () => _handleFacebookLogin(),
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 11),
                color: Colors.white,
                child: SizedBox(
                    width: 247,
                    height: 40,
                    child: Row(children: [
                      Image.asset('assets/google_logo.png', height: 18),
                      SizedBox(width: 24),
                      Text('Continue with Google'),
                    ])),
                onPressed: () => _handleGoogleLogin(),
              ),
              Padding(padding: EdgeInsets.all(15)),
              FlatButton(
                child: Text('or continue as Guest'),
                onPressed: () => _handleAnonLogin(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFacebookLogin() async {
    FacebookLoginResult result =
        await FacebookLogin().logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        setState(() => _isLoading = true);
        AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        FirebaseUser user = await Global.auth.signInWithCredential(credential);
        Global.userId = await user.getIdToken();
        setState(() => _isLoading = false);
        redirect();
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        throw Exception(result.errorMessage);
    }
  }

  void _handleGoogleLogin() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    setState(() => _isLoading = true);
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser firebaseUser =
        await Global.auth.signInWithCredential(credential);
    Global.userId = await firebaseUser.getIdToken();
    setState(() => _isLoading = false);
    redirect();
  }

  void _handleAnonLogin() async {
    setState(() => _isLoading = true);
    FirebaseUser user = await Global.auth.signInAnonymously();
    Global.userId = await user.getIdToken();
    setState(() => _isLoading = false);
    redirect();
  }

  void redirect() {
    Navigator.of(context).pushReplacementNamed('/events');
  }
}
