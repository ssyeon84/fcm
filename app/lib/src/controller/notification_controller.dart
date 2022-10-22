import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:app/src/common/constants.dart';
import 'package:app/src/page/webview_page.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // TODO data?
  Get.log('${notificationResponse}');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationController extends GetxController {

  final String defaultWebviewURL = GlobalConfiguration().getValue("defaultWebviewURL");

  static NotificationController get to => Get.find();
  Map<String, dynamic>? messageData;
  String? deviceToken;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannelGroup channel;
  bool isFlutterLocalNotificationsInitialized = false;

  @override
  void onInit() async {
    super.onInit();

    // firebase core init
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // local notification init
    _setupNotification();

    // firebase init
    _initNotification();
  }

  void _initNotification() async {
    // 전체발송을 위함 topic 구독
    // 기존에 구독한것이 있다면 구독취소 먼저 실행하고 새로운 구독을 실행
    await unSubscribe();
    await subscribe();

    FirebaseMessaging.onMessage.listen((message) {
      Get.log('# [ FCM onMessage ]');
      messageData = message.data;
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Get.log('# [ FCM onMessageOpenedApp (background -> open) ]');
      messageData = message.data;
      pushMovePage();
    });

    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message) {
      Get.log('# [ FCM initialMessage (terminated -> open) ]');
      if (message != null) {
        messageData = message.data;
        Get.log('### FCM initialMessage ${messageData}');
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      Get.log('# [ FCM Token ] : ${token.toString()}');
      deviceToken = token;
    });
  }

  _setupNotification() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    channel = const AndroidNotificationChannelGroup(
      'app-channel-id', // id
      'fcm test', // title
      description: 'fcm group test'
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannelGroup(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  // 웹뷰 페이지로 이동
  void pushMovePage() async {
    String directUrl = defaultWebviewURL;
    if (messageData != null && messageData!.containsKey('url')) {
      directUrl = messageData!['url'];
    }
    Get.offAll(WebviewPage(url: directUrl));
  }


  // 전체발송 구독
  static Future<void> subscribe() async {
    await FirebaseMessaging.instance.subscribeToTopic(Constants.fcmTopicKey);
  }

  // 전체발송 구독취소
  static Future<void> unSubscribe() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(
        Constants.fcmTopicKey);
  }

  void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              groupKey: channel.id),
        ),
      );
    }
    groupNotification();
  }

  void groupNotification() async {
    // 메세지 그룹핑
    List<ActiveNotification>? activeNotifications = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
    if (activeNotifications != null && activeNotifications.isNotEmpty) {
      List<String> lines = activeNotifications.map((e) => e.title.toString())
          .toList();
      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: "${activeNotifications.length - 1} Updates",
        summaryText: "${activeNotifications.length - 1} Updates",
      );
      AndroidNotificationDetails groupNotificationDetails =
      AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        styleInformation: inboxStyleInformation,
        setAsGroupSummary: true,
        groupKey: channel.id,
        // onlyAlertOnce: true,
      );
      NotificationDetails groupNotificationDetailsPlatformSpefics =
      NotificationDetails(android: groupNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          0, '', '', groupNotificationDetailsPlatformSpefics);
    }
  }
}