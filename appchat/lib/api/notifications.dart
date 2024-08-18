import 'dart:convert';
import 'dart:developer';

import 'package:appchat/api/apis.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

// Initialize Flutter Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Initialize Flutter Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Set up Firebase Messaging
    await getMessageToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  static Future<void> getMessageToken() async {
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((t) {
      if (t != null) {
        Apis.me.pushToken = t;
        log('Push Token : $t');
      }
    });
  }

  static Future<String> getAccessToken() async {
    String fMessagingScope =
        "https://www.googleapis.com/auth/firebase.messaging";
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(dotenv.env["GOOGLECREDENTIAL"]),
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

  static void _handleMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Create a notification channel if it doesn't exist
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Show the notification
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }
}
