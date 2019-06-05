import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

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
                color: Color(0xFF4267B2),
                child: SizedBox(
                  width: 247,
                  height: 40,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/facebook_logo.png',
                        height: 18,
                      ),
                      SizedBox(width: 24),
                      Text(
                        'Continue with Facebook',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  handleFacebookLogin()
                      .then((FirebaseUser user) => alert(user))
                      .catchError((e) => alert(e));
                },
              ),
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
                      Text('Continue with Google'),
                    ],
                  ),
                ),
                onPressed: () {
                  handleGoogleLogin()
                      .then((FirebaseUser user) => alert(user))
                      .catchError((e) => alert(e));
                },
              ),
              Padding(
                padding: EdgeInsets.all(15),
              ),
              Text('or continue as guest')
            ],
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> handleFacebookLogin() async {
    FacebookLogin facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);
    FacebookAccessToken token = facebookLoginResult.accessToken;
    AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: token.token);
    FirebaseUser user =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return user;
  }

  Future<FirebaseUser> handleGoogleLogin() async {
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

  alert(x) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            content: ListView(
              children: [
                Text(x.toString()),
              ],
            ),
          ),
    );
  }
}
