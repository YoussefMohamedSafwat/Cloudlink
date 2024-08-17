import 'dart:io';

import 'package:appchat/Screens/widgets/ImageButton.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dat_utill.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Viewprofile extends StatefulWidget {
  const Viewprofile({super.key, required this.currentUser});

  final ChatUser currentUser;

  @override
  State<Viewprofile> createState() => _ViewprofileState();
}

class _ViewprofileState extends State<Viewprofile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.currentUser.name),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: RichText(
              text: TextSpan(children: [
            const TextSpan(
                text: 'Joined on: ',
                style: TextStyle(color: Colors.lightBlue, fontSize: 22)),
            TextSpan(
                text: MyDateUtill.getlastMessageTime(
                    context: context,
                    time: widget.currentUser.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black, fontSize: 22))
          ])),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.1),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          height: mq.height * 0.2,
                          width: mq.height * 0.2,
                          imageUrl: widget.currentUser.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(
                              CupertinoIcons.person,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.currentUser.email,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                      text: 'about: ',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 22)),
                  TextSpan(
                      text: widget.currentUser.about,
                      style: const TextStyle(color: Colors.black, fontSize: 22))
                ])),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
