import 'dart:convert';
import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  static Future<void> getMessageToken() async {
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((t) {
      if (t != null) {
        Apis.me.pushToken = t;
        log('Push Token : $t');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log('Message contained a notification : ${message.notification}');
      }
    });
  }

  static Future<String> getAccessToken() async {
    String fMessagingScope =
        "https://www.googleapis.com/auth/firebase.messaging";
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({dotenv.env["GOOGLECREDENTIAL"]}),
      [fMessagingScope],
    );

    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }

  static Future<void> sendPushNotification(
      ChatUser chatuser, String msg) async {
    String notificationEndPoint =
        "https://fcm.googleapis.com/v1/projects/${dotenv.env["project_id"]}/messages:send";
    String bearerToken = await getAccessToken();
    final body = {
      "message": {
        "token": chatuser.pushToken,
        "notification": {
          "title": Apis.me.name,
          "body": msg,
        }
      }
    };

    try {
      final http.Response response = await http.post(
          Uri.parse(notificationEndPoint),
          headers: <String, String>{
            "Content-Type": "application/json",
            "Authorization": 'Bearer $bearerToken'
          },
          body: jsonEncode(body));
      log("response status code: ${response.statusCode}");
      log("response body : ${response.body}");
    } catch (e) {
      log('response error  : $e');
    }
  }
}
