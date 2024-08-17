import 'dart:developer';

import 'package:appchat/api/FriendApi.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: Colors.blue.withOpacity(0.8)));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }

  static showMessageUpdateDialog(BuildContext context, Message msg) {
    String UpdateMsg = msg.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text("Update message")
                ],
              ),
              content: TextFormField(
                initialValue: UpdateMsg,
                onChanged: (value) => UpdateMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Apis.UpdateMessage(msg, UpdateMsg);
                    Navigator.pop(context); // Close the dialog after saving
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }

  static addUser(BuildContext context) {
    String Email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text("Add user")
                ],
              ),
              content: TextFormField(
                onChanged: (value) => Email = value,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    hintText: "Email id",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (Email.isNotEmpty) {
                      await Friendapi.sendFriendreq(Email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, "User does not exists");
                        } else {
                          log("value is ${value}");
                        }
                      });
                    }
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
