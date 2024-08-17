import 'package:appchat/main.dart';
import 'package:flutter/material.dart';

class Imagebutton extends StatelessWidget {
  Imagebutton(
      {super.key,
      required this.image,
      required this.path,
      required this.onPressed});

  final String path;
  String? image;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            fixedSize: Size(mq.width * 0.3, mq.height * 0.15)),
        onPressed: onPressed,
        child: Image.asset(
          path,
        ));
  }
}
