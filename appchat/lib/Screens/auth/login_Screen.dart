import 'dart:developer';
import 'dart:io';

import 'package:appchat/Screens/home_Screen.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/res/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  _handleGoogleSignIn() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\n UserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await Apis.userExists())) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await Apis.createUser().then((value) => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()))
              });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      print('\nsignInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'something went wrong, check internet');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to CloudLink"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset('assets/images/applogo.png'))),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * 0.9,
              left: mq.width * 0.05,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.9),
                    //const Color.fromARGB(255, 223, 255, 187),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleSignIn();
                },
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mq.height * .03,
                ),
                label: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            color: AppColors.textColor_black, fontSize: 19),
                        children: const [
                      TextSpan(text: "Sign In with"),
                      TextSpan(
                          text: " Google",
                          style: TextStyle(fontWeight: FontWeight.w500))
                    ])),
              ))
        ],
      ),
    );
  }
}
