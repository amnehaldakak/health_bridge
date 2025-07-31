import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirebaseApi {
  BuildContext? context;
  // create instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initalize the notification
  Future<void> initNotification() async {
    //request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();
    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    //print the token
    print('Token: ' + fCMToken.toString());

    initPushNotification();
  }

  // funtion to handle the recve messages
  void handleMessage(RemoteMessage? message) async {
    //check if the message is null
    if (message == null) return;
    //check if the message is a data message
    context!.goNamed('notification',
        pathParameters: {'message': message.data.toString()});
    //if the message is a notification message
    //context!.goNamed('notification',pathParameters:
  }

  //function to initialize forground and background setting
  Future initPushNotification() async {
    //register the message listener
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    //register the background messaonMessagege listener
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
