import 'package:appchat/main.dart';
import 'package:flutter/material.dart';

class OptionItem extends StatelessWidget {
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.025),
        child: Row(
          children: [
            icon,
            const SizedBox(
              width: 8,
            ),
            Flexible(
                child: Text(
              name,
              style: TextStyle(
                  fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
