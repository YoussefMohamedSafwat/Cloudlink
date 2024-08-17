import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyDateUtill {
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch((int.parse(time)));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getlastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear
        ? '${sent.day} ${_getMonth(sent)} ${sent.year}'
        : '${sent.day} ${_getMonth(sent)}';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    log(i.toString());

    if (i == -1) return 'last seen not available';

    DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);

    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);

    log(time.day.toString());
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'last seen today at $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'last seen yesterday at $formattedTime';
    }

    String month = _getMonth(time);
    return 'last seen on ${time.day} $month on $formattedTime';
  }

  static String getMessagetime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    String formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (sent.day == now.day &&
        sent.month == now.month &&
        sent.year == now.year) {
      return '$formattedTime';
    }

    return now.year == sent.year
        ? '${formattedTime} - ${sent.day} ${_getMonth(sent)}'
        : '${formattedTime} - ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';

      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';

      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
