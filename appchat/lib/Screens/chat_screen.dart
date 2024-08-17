import 'dart:developer';

import 'package:appchat/Screens/viewProfile.dart';
import 'package:appchat/Screens/widgets/Stream.dart';
import 'package:appchat/Screens/widgets/chat_field.dart';
import 'package:appchat/Screens/widgets/message_card.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dat_utill.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  List<Message> _oldlist = [];

  QuerySnapshot? previousSnapshot;
  final ScrollController _scrollController = ScrollController();

  final _textController = TextEditingController();
  bool _showEmoji = false, _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
        }
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        onPopInvoked: (didPop) {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          }
        },
        canPop: _showEmoji ? false : true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: StreamBuilder(
                stream: Apis.getUserInfo(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                Viewprofile(currentUser: widget.user))),
                    child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.3),
                          child: CachedNetworkImage(
                            imageUrl: list.isNotEmpty
                                ? list[0].image
                                : widget.user.image,
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
                        title: Text(widget.user.name),
                        subtitle: Text(list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtill.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtill.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive))),
                  );
                }),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Apis.getallmMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            final newList = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            // Check if the new list is different from the old list
                            if (_list.length != newList.length) {
                              _oldlist = _list; // Update old list
                              _list = newList; // Set new list
                            }
                            // Compare with previous snapshot

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  key: ValueKey(_list.length),
                                  itemCount: _list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * 0.01),
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
                                  });
                            } else {
                              return const Center(
                                child: Text('Say Hii! 👋',
                                    style: TextStyle(fontSize: 20)),
                              );
                            }
                        }
                      }),
                ),
                const SizedBox(
                  height: 40,
                ),
                _isuploading
                    ? const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox(),
                ChatField(
                  controller: _textController,
                  to_user: widget.user,
                  onPressedEmo: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                  },
                  onPressedKey: () {
                    if (_showEmoji)
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                  },
                  setLoading: () {
                    setState(() {
                      _isuploading = !_isuploading;
                    });
                  },
                ),
                Offstage(
                  offstage: !_showEmoji,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      height: 256,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        // Issue: https://github.com/flutter/flutter/issues/28894
                        emojiSizeMax: 28 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.2
                                : 1.0),
                      ),
                      swapCategoryAndBottomBar: false,
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(),
                      bottomActionBarConfig: const BottomActionBarConfig(),
                      searchViewConfig: const SearchViewConfig(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
