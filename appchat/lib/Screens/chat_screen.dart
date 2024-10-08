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

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  List<Message> _list = [];
  bool _isuploading = false, _showEmoji = false;
  final _textController = TextEditingController();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the state is kept alive

    ;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: StreamBuilder(
            stream: Apis.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Viewprofile(currentUser: widget.user))),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
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
                  title: Text(widget.user.name),
                  subtitle: Text(list.isNotEmpty
                      ? list[0].isOnline
                          ? 'Online'
                          : MyDateUtill.getLastActiveTime(
                              context: context, lastActive: list[0].lastActive)
                      : MyDateUtill.getLastActiveTime(
                          context: context,
                          lastActive: widget.user.lastActive)),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: Apis.getallmMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "Say hi👋🏻",
                              style: TextStyle(fontSize: 25),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              const SizedBox(height: 40), // Adjust this as necessary
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
    );
  }
}
