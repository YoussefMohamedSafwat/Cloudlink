import 'dart:convert';
import 'dart:developer';

import 'package:appchat/Screens/profile.dart';
import 'package:appchat/Screens/requests.dart';

import 'package:appchat/Screens/widgets/chat_user_card.dart';
import 'package:appchat/api/FriendApi.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/lists.dart';
import 'package:appchat/res/styles/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Apis.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (Apis.auth.currentUser != null) {
        if (message?.contains('pause') ?? false) {
          await Apis.updateActiveStatus(false);
        }
        if (message?.contains('resume') ?? false) {
          await Apis.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchList
        ..clear()
        ..addAll(
          list.where(
            (user) =>
                user.name.toLowerCase().contains(value.toLowerCase()) ||
                user.email.toLowerCase().contains(value.toLowerCase()),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvoked: (didPop) {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
            });
          }
        },
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name, Email, ....'),
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      autofocus: true,
                      onChanged: _onSearchChanged,
                    )
                  : const Text("CloudLink"),
              // leading: IconButton(
              //     onPressed: () {}, icon: const Icon(CupertinoIcons.home)),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled
                        : Icons.search)),
                StreamBuilder(
                    stream: Friendapi.getFriendRequests(),
                    builder: (context, snapshots) {
                      if (snapshots.hasData) {
                        final data = snapshots.data?.docs;

                        requests = data?.map((e) => e.id).toList() ?? [];
                      }
                      return Stack(children: [
                        IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Requests())),
                            icon: const Icon(Icons.person_add)),
                        Positioned(
                            top: 0,
                            right: -4,
                            child: UnreadMessageBadge(
                              unreadCount: requests.length,
                              color: Colors.red,
                            ))
                      ]);
                    }),
                IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Profile(currentUser: Apis.me))),
                    icon: const Icon(Icons.person_2_rounded))
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  backgroundColor: AppColors.appBar_Color,
                  onPressed: () {
                    Dialogs.addUser(context);
                  },
                  child: const Icon(
                    Icons.add_comment_rounded,
                    color: Colors.white,
                  )),
            ),
            body: StreamBuilder(
              stream: Friendapi.getFriends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  log('Stream error: ${snapshot.error}');
                  return const Center(
                    child: Text(
                      "Something went wrong!",
                      style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "No users found.",
                      style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic),
                    ),
                  );
                } else {
                  final data = snapshot.data?.docs;
                  return (StreamBuilder(
                      stream: Friendapi.showRequests(
                          data?.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshots) {
                        if (snapshots.hasData) {
                          final friends = snapshots.data?.docs;
                          list = friends
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          return ListView.builder(
                            itemCount:
                                _isSearching ? _searchList.length : list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : list[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "No users found",
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                      }));

                  // Safeguard if data is null or empty
                }
              },
            )),
      ),
    );
  }
}
