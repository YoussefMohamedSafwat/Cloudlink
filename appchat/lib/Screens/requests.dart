import 'dart:developer';

import 'package:appchat/Screens/widgets/chat_user_card.dart';
import 'package:appchat/Screens/widgets/request_card.dart';
import 'package:appchat/api/FriendApi.dart';
import 'package:appchat/api/apis.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/lists.dart';
import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  late Future<List<ChatUser>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchRequests();
  }

  Future<List<ChatUser>> _fetchRequests() async {
    final snapshot = await Friendapi.showRequests(requests).first;
    final data = snapshot.docs;
    return data.map((e) => ChatUser.fromJson(e.data())).toList();
  }

  Future<void> _handleRequest(ChatUser user, bool isConfirmed) async {
    if (isConfirmed) {
      await Friendapi.addFriend(user);
    }
    await Friendapi.removeRequest(user);

    // Remove the request locally and refresh the Future
    setState(() {
      requests.removeWhere((id) => id == user.id);
      _requestsFuture = _fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend requests"),
      ),
      body: FutureBuilder<List<ChatUser>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final requestList = snapshot.data!;
            if (requestList.isEmpty) {
              return const Center(
                child: Text(
                  "No requests for now",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }

            return ListView.builder(
              itemCount: requestList.length,
              itemBuilder: (context, index) {
                return RequestCard(
                  user: requestList[index],
                  onConfirm: () => _handleRequest(requestList[index], true),
                  onRemove: () => _handleRequest(requestList[index], false),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No requests for now",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
        },
      ),
    );
  }
}
