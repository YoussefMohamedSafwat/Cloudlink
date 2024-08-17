import 'package:appchat/Screens/auth/login_Screen.dart';
import 'package:appchat/Screens/home_Screen.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      //navigate
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Apis.auth.currentUser != null
                ? const HomeScreen()
                : const LoginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      //body
      body: Stack(children: [
        //app logo
        Positioned(
            top: mq.height * .25,
            right: mq.width * .25,
            width: mq.width * .5,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset('assets/images/applogo.png'))),

        //google login button
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text('Chat with friends ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
