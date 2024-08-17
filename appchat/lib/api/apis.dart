import 'dart:developer';
import 'dart:io';

import 'package:appchat/api/notifications.dart';
import 'package:appchat/models/chat_message.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static late ChatUser me;

  static Future<bool> userExists() async {
    return (await firestore.collection('Users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('Users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await NotificationService.getMessageToken();
        Apis.updateActiveStatus(true);
      } else {
        await createUser().then((values) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        name: user.displayName.toString(),
        about: "",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: user.uid,
        pushToken: "",
        email: user.email.toString(),
        image: user.photoURL!);

    firestore.collection('Users').doc(user.uid).set(chatuser.toJson());
    firestore.collection('Users').doc(user.uid).collection("friends");
    firestore.collection('Users').doc(user.uid).collection("friend requests");
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getallUsers() {
    return firestore
        .collection('Users')
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatuser) {
    return firestore
        .collection('Users')
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) {
    return firestore.collection('Users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Future<void> UpdateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Trasnferred : ${p0.bytesTransferred / 1000}kb');
    });

    me.image = await ref.getDownloadURL();
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'image': me.image});
  }
// chat related code //////////////

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getallmMessages(
      ChatUser user) {
    log('chats/${getConversationID(user.id)}/messages/');
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    log('chats/${getConversationID(chatuser.id)}/messages/');

    final Message message = Message(
        msg: msg,
        toId: chatuser.id,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatuser.id)}/messages/');

    await ref.doc(time).set(message.toJson()).then((onValue) =>
        NotificationService.sendPushNotification(
            chatuser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({"read": DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getlastMessage(
      ChatUser user) async* {
    var ref = firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .where('read', isEqualTo: "");

    var refsnapshot = await ref.get();

    if (refsnapshot.docs.isNotEmpty) {
      yield* ref.snapshots();
    } else {
      yield* firestore
          .collection('chats/${getConversationID(user.id)}/messages/')
          .orderBy('read', descending: true)
          .limit(1)
          .snapshots();
    }
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> UpdateMessage(
      Message message, String updatedmessage) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({"msg": updatedmessage});
  }

  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    final ref = storage.ref().child(
        'images//${getConversationID(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Trasnferred : ${p0.bytesTransferred / 1000}kb');
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);
  }
}
