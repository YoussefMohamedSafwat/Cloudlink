import 'package:appchat/api/FriendApi.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/lists.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.user,
    required this.onConfirm,
    required this.onRemove,
  });

  final ChatUser user;
  final VoidCallback onConfirm;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.1),
              child: CachedNetworkImage(
                imageUrl: user.image,
                height: mq.height * 0.08,
                width: mq.height * 0.08,
                fit: BoxFit.cover,
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
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                user.name,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 30),
            MaterialButton(
              onPressed: onConfirm,
              child: const Text(
                "Confirm",
                style: TextStyle(
                    fontSize: 15, color: Colors.blue, letterSpacing: 0.5),
              ),
            ),
            MaterialButton(
              onPressed: onRemove,
              child: const Text(
                "Remove",
                style: TextStyle(
                    fontSize: 15, color: Colors.red, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
