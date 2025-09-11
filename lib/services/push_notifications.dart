import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/database/db_provider.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<String> _messageStream = StreamController.broadcast();
  static Stream<String> get messagesStream => _messageStream.stream;

  static Future initializeapp() async {
    //push notifications
    await Firebase.initializeApp();

    await requestPermission();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.getToken().then((v) {}).catchError((err) {
      debugPrint('error $err');
    });
    // debugPrint('tokenNotification $token');

    //cuando esta en segundo plano la app
    FirebaseMessaging.onBackgroundMessage(_backgroundHandle);
    //cuando esta en primer plano la app
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {}).onData((data) => _onMessageHandler(data));
    //cuando se abre la app desde la notificacion y la app esta en segundo plano pero no esta cerrado del todo
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }
@pragma('vm:entry-point')
  static Future<void> _backgroundHandle(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('_backgroundHandle ${json.encode(message.data)}');
    final affiliateId = await DBProvider.db.getAffiliateModelById();
    final notification = NotificationModel(
        title: message.data['title'],
        idAffiliate: affiliateId,
        content: json.encode(message.data),
        read: false,
        date: DateTime.now());
        
    await DBProvider.db.newNotificationModel(notification);
    debugPrint('REGISTRADO');
  }

  static _onMessageHandler(RemoteMessage message) async {
    debugPrint('_onMessageHandler ${message.data}');
    final affiliateId = await DBProvider.db.getAffiliateModelById();
    final notification = NotificationModel(
        title: message.data['title'],
        idAffiliate: affiliateId,
        content: json.encode(message.data),
        read: false,
        date: DateTime.now());
    await DBProvider.db.newNotificationModel(notification);
    debugPrint('REGISTRADO');
    message.data['origin'] = '_onMessageHandler';
    _messageStream.add(json.encode(message.data));
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    debugPrint('_onMessageOpenApp');
    _messageStream.add(json.encode(message.data));
  }

  static requestPermission() async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(badge: true, alert: true, sound: true);
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User push notification status ${settings.authorizationStatus}');
  }

  static closeStreams() async {
    // _messageStream.close();
    // await Firebase.
  }
  static Future getTokenFirebase() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
