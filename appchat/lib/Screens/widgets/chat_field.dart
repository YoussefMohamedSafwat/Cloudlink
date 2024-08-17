import 'dart:developer';
import 'dart:io';

import 'package:appchat/api/apis.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatField extends StatefulWidget {
  const ChatField(
      {super.key,
      required this.controller,
      required this.to_user,
      required this.onPressedEmo,
      required this.onPressedKey,
      required this.setLoading});

  final TextEditingController controller;
  final ChatUser to_user;

  final onPressedEmo;

  final onPressedKey;

  final setLoading;

  @override
  State<ChatField> createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  IconButton(
                      onPressed: widget.onPressedEmo,
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blue,
                      )),
                  Expanded(
                      child: TextField(
                    controller: widget.controller,
                    keyboardType: TextInputType.multiline,
                    onTap: widget.onPressedKey,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Tpe Something...",
                        hintStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          log('Image Path : ${i.path}');
                          widget.setLoading();
                          await Apis.sendChatImage(
                              widget.to_user, File(i.path));
                          widget.setLoading();
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          widget.setLoading();
                          Apis.sendChatImage(widget.to_user, File(image.path));
                          widget.setLoading();
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            shape: const CircleBorder(),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            onPressed: () {
              if (widget.controller.text.isNotEmpty) {
                setState(() {
                  Apis.sendMessage(
                      widget.to_user, widget.controller.text, Type.text);
                  widget.controller.text = '';
                });
              }
            },
            minWidth: 0,
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
