import 'dart:developer';

import 'package:appchat/Screens/widgets/option_item.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dat_utill.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        FocusScope.of(context).unfocus();
        _showBottomSheet(context, isMe);
      },
      child: isMe ? _greenMessage(context) : _blueMessage(context),
    );
  }

  Widget _blueMessage(BuildContext context) {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: const BoxDecoration(
                color: Colors.lightBlue,
                // color: Color.fromARGB(255, 221, 245, 255)
                // ,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.04,
            ),
            Text(
              MyDateUtill.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(width: 2),
          ],
        )
      ],
    );
  }

  Widget _greenMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.04,
            ),
            widget.message.read.isNotEmpty
                ? const Icon(Icons.done_all_rounded, color: Colors.blue)
                : const Icon(Icons.done),
            const SizedBox(width: 2),
            Text(
              MyDateUtill.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == Type.image ? mq.width * 0.03 : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  _showBottomSheet(BuildContext context, bool isme) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? OptionItem(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        log("i am here ");
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, "Text copied !");
                        });
                      })
                  : OptionItem(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Save image",
                      onTap: () async {
                        String path = widget.message.msg;
                        try {
                          GallerySaver.saveImage(path, albumName: "chat app")
                              .then((succes) {
                            if (succes != null) {
                              Navigator.pop(context);
                              Dialogs.showSnackbar(context, "Image saved!");
                            }
                          });
                        } catch (e) {
                          log("Error saving img : $e");
                        }
                      }),
              if (isme)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * 0.04,
                  indent: mq.width * 0.04,
                ),
              if (widget.message.type == Type.text && isme)
                OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    name: "Edit message",
                    onTap: () async {
                      Navigator.pop(context);
                      Dialogs.showMessageUpdateDialog(context, widget.message);
                    }),
              if (isme)
                OptionItem(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    name: "Delete message",
                    onTap: () {
                      Apis.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),
              OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      "Sent at:  ${MyDateUtill.getFormattedTime(context: context, time: widget.message.sent)} ",
                  onTap: () {}),
              OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  name: widget.message.read.isEmpty
                      ? "Read at : not seen "
                      : "Read at: ${MyDateUtill.getFormattedTime(context: context, time: widget.message.read)}",
                  onTap: () {}),
            ],
          );
        });
  }
}
