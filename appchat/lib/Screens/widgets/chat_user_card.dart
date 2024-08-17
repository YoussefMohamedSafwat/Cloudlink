import 'dart:developer';

import 'package:appchat/Screens/chat_screen.dart';
import 'package:appchat/Screens/widgets/profile_dialog.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dat_utill.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatCard extends StatefulWidget {
  final ChatUser user;

  ChatCard({super.key, required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatScreen(
                      user: widget.user,
                    )));
          },
          child: StreamBuilder(
            stream: Apis.getlastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              List<Message> list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              int unreadCount = list
                  .where((message) =>
                      message.read == "" && message.fromId != Apis.me.id)
                  .length;
              if (list.isNotEmpty) {
                _message = list[list.length - 1];
              }
              return ListTile(
                leading: Stack(
                  children: [
                    InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(
                                user: widget.user,
                              )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.1),
                        child: CachedNetworkImage(
                          imageUrl: widget.user.image,
                          width: mq.height * 0.05,
                          height: mq.height * 0.05,
                          fit: BoxFit.cover,
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
                    ),
                    Positioned(
                      right: 5,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.user.isOnline
                                ? Colors.greenAccent.shade400
                                : Colors.blueGrey),
                      ),
                    )
                  ],
                ),
                title: Text(widget.user.name),
                subtitle: _message?.type == Type.image
                    ? const Row(
                        children: [
                          Icon(Icons.image),
                          SizedBox(
                            height: 5,
                          ),
                          Text("image ")
                        ],
                      )
                    : Text(
                        _message != null ? _message!.msg : widget.user.about,
                        maxLines: 1,
                      ),
                trailing: Column(
                  children: [
                    messageDate(),
                    UnreadMessageBadge(
                      unreadCount: unreadCount,
                      color: Colors.blue,
                    )
                  ],
                )

                //  unreadCount > 0 ? Text("$unreadCount") : null,
                ,
                titleTextStyle:
                    const TextStyle(fontSize: 15, color: Colors.black),
              );
            },
          )),
    );
  }

  Widget messageDate() {
    if (_message != null) {
      return Text(MyDateUtill.getlastMessageTime(
          context: context, time: _message!.sent));
    } else {
      return const SizedBox();
    }
  }
}

class UnreadMessageBadge extends StatelessWidget {
  const UnreadMessageBadge(
      {super.key, required this.unreadCount, required this.color});

  final int unreadCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (unreadCount > 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Text(
            "$unreadCount",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
