
import 'package:firebase/firebase_messaging/custom_local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CustomFirebaseMessaging {
  final CustomLocalNotification _customLocalNotification;

  CustomFirebaseMessaging._internal(this._customLocalNotification);

  static final CustomFirebaseMessaging _singleton = 
    CustomFirebaseMessaging._internal(CustomLocalNotification());
  factory CustomFirebaseMessaging() => _singleton;

  Future<void> inicialize({VoidCallback? callback}) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(badge: true,sound: true);

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if(message.data['forceFatch'] != null) {
        callback?.call();
        return;
      }
      //forma de travar a continuidade do codigo

      if(notification != null && android != null){
        _customLocalNotification.androidNotification(notification,android);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) { 
      if(message.data['forceFatch'] != null) callback?.call();
      navigatorKey.currentState?.pushNamed(message.data['goTO']);
    });
  }

  getTokenFirebase() async => 
      debugPrint(await FirebaseMessaging.instance.getToken());

  

}