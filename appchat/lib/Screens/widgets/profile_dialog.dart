import 'package:appchat/Screens/viewProfile.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * 0.35,
        child: Stack(
          children: [
            Positioned(
              left: mq.width * 0.04,
              top: mq.height * 0.02,
              width: mq.width * 0.55,
              child: Text(user.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.25),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  fit: BoxFit.cover,
                  width: mq.width * 0.5,
                  height: mq.height * 0.25,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(
                      CupertinoIcons.person,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Viewprofile(currentUser: user)));
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
