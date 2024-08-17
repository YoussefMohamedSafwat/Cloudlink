import 'package:appchat/api/apis.dart';
import 'package:appchat/api/notifications.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Friendapi {
  static Future<bool> sendFriendreq(String email) async {
    final data = await Apis.firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != Apis.user.uid) {
      Apis.firestore
          .collection('Users')
          .doc(data.docs.first.id)
          .collection("friend requests")
          .doc(Apis.user.uid)
          .set({});

      NotificationService.sendPushNotification(
          ChatUser.fromJson(data.docs.first.data()),
          "sent you a friend request");
      return true;
    }
    return false;
  }

  static Future<void> addFriend(ChatUser chatuser) async {
    Apis.firestore
        .collection('Users')
        .doc(Apis.me.id)
        .collection("Friends")
        .doc(chatuser.id)
        .set({});
    Apis.firestore
        .collection('Users')
        .doc(chatuser.id)
        .collection("Friends")
        .doc(Apis.me.id)
        .set({});

    Apis.firestore
        .collection('Users')
        .doc(Apis.me.id)
        .collection("friend requests")
        .doc(chatuser.id)
        .delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getFriendRequests() {
    return Apis.firestore
        .collection('Users')
        .doc(Apis.user.uid)
        .collection('friend requests')
        .snapshots();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getFriends() {
    return Apis.firestore
        .collection('Users')
        .doc(Apis.user.uid)
        .collection('Friends')
        .snapshots();
  }
  

  static Stream<QuerySnapshot<Map<String, dynamic>>> showRequests(
      List<String> ids) {
    if (ids.isNotEmpty) {
      return Apis.firestore
          .collection('Users')
          .where('id', whereIn: ids)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  static removeRequest(ChatUser chatuser) {
    Apis.firestore
        .collection('Users')
        .doc(Apis.me.id)
        .collection('friend requests')
        .doc(chatuser.id)
        .delete();
  }
}
