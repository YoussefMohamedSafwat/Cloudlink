import 'dart:developer';

import 'package:appchat/Screens/widgets/chat_user_card.dart';
import 'package:appchat/Screens/widgets/message_card.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:flutter/material.dart';

class Stream extends StatelessWidget {
  Stream(
      {super.key,
      required this.text,
      required this.is_user,
      this.messagelist = const [],
      this.list = const [],
      this.user,
      this.is_searching = false});

  final String text;
  List<ChatUser> list;
  List<Message> messagelist;
  final bool is_user;

  ChatUser? user;
  final bool is_searching;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: is_user ? Apis.getallUsers() : Apis.getallmMessages(user!),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.none:
              return const Center(
                  child: Text(
                "Something went wrong!",
                style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                    fontStyle: FontStyle.italic),
              ));
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;

              if (is_user && !is_searching) {
                userlist =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];
                list = userlist;
              } else {
                messagelist =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                // messagelist
                //     .sort((first, sec) => first.sent.compareTo(sec.sent));
              }

          

              return ListView.builder(
                  itemCount: is_user ? list.length : messagelist.length,
                  padding: EdgeInsets.only(top: mq.height * 0.01),
                  physics: const BouncingScrollPhysics(),
                  reverse: is_user ? false : true,
                  itemBuilder: (context, index) {
                    return is_user
                        ? ChatCard(user: list[index])
                        : MessageCard(message: messagelist[index]);
                  });
          }
        });
  }
}
