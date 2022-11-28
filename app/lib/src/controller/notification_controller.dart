import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:app/src/common/constants.dart';


late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannelGroup channel;
bool isFlutterLocalNotificationsInitialized = false;

/////////////////////////////
// fcm background noti 처리 //
/////////////////////////////
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupNotification();
  showNotification(message);

  // TODO terminated -> open 용 storage 저장
  // (background -> open) 일 경우에도 저장됨
  var storage = const FlutterSecureStorage();
  storage.write(key: "message", value: jsonEncode(message?.data));
  print('# firebaseMessagingBackgroundHandler ${message?.data}');
}

/////////////////////////////////
// notification 클릭 이벤트 처리 //
/////////////////////////////////
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // handle action
  if (Constants.isNotBlank(notificationResponse.payload)) {
    NotificationController.to.messageData.value = jsonDecode(notificationResponse.payload!);
    print('# message click => ${NotificationController.to.messageData}');
    // (background -> open) 일 경우 저장된 storage 삭제
    var storage = const FlutterSecureStorage();
    await storage.delete(key: "message");
  }
}
@pragma('vm:entry-point')
void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
}

////////////////////////////
// local notification 셋팅 //
////////////////////////////
setupNotification() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification)
    ),
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  channel = const AndroidNotificationChannelGroup('webview-channel-id', '바이나우', description: '바이나우');
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannelGroup(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: false,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showNotification(RemoteMessage message) async {
  // data 에 title, body를 담아 메세지를 보여준다
  Map<String, dynamic> data = message.data;
  flutterLocalNotificationsPlugin.show(
    message.hashCode,
    data['title'],
    data['body'],
    payload: jsonEncode(message.data),
    NotificationDetails(
      android: AndroidNotificationDetails(channel.id, channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: channel.id),
    ),
  );
  showGroupNotification();
}

void showGroupNotification() async {
  // 메세지 그룹핑
  List<ActiveNotification>? activeNotifications =
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();
  if (activeNotifications != null && activeNotifications.isNotEmpty) {
    List<String> lines =
    activeNotifications.map((e) => e.title.toString()).toList();
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
    );
    NotificationDetails groupNotificationDetailsPlatformSpefics =
    NotificationDetails(android: groupNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, '', '', groupNotificationDetailsPlatformSpefics);
  }
}

/////////////////////////////
// Notification Controller //
/////////////////////////////

class NotificationController extends GetxController {

  static NotificationController get to => Get.find();
  Rx<RemoteMessage> remoteMessage = const RemoteMessage().obs;
  RxMap<String, dynamic> messageData = RxMap<String, dynamic>({});
  RxString deviceToken = "".obs;

  @override
  void onInit() async {
    super.onInit();

    // firebase core init
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 전체발송을 위함 topic 구독
    // 기존에 구독한것이 있다면 구독취소 먼저 실행하고 새로운 구독을 실행
    await unSubscribe();
    await subscribe();

    // firebase init
    FirebaseMessaging.onMessage.listen((message) {
      Get.log('# [ FCM onMessage ]');
      showNotification(message);
    });

    // TODO terminated -> open 용 data init
    var storage = const FlutterSecureStorage();
    var messageStr = await storage.read(key: "message");
    if(messageStr != null) {
      NotificationController.to.messageData.value = jsonDecode(messageStr);
      print('# message click => ${NotificationController.to.messageData}');
      await storage.delete(key: "message");
    }

    // TODO not working
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Get.log('# [ FCM onMessageOpenedApp (background -> open) ]');
      remoteMessage.value = message;
      messageData.value = message.data;
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      Get.log('# [ FCM initialMessage (terminated -> open) ] ${message?.data}');
      if (message != null) {
        remoteMessage.value = message;
        messageData.value = message.data;
      }
    });

    // local notification init
    setupNotification();

    String fcmKey = "fcmToken";
    const secureStorage = FlutterSecureStorage();
    String? storeToken = await secureStorage.read(key: fcmKey);
    if (storeToken != null) {
      deviceToken.value = storeToken;
    }

    FirebaseMessaging.instance.getToken().then((token) async {
      Get.log('# [ FCM Token ] : ${token.toString()}');
      if (token != null && token != "" && deviceToken.value != token) {
        deviceToken.value = token;
        secureStorage.write(key: fcmKey, value: token);
      }
    });
  }

  // 전체발송 구독
  static Future<void> subscribe() async {
    await FirebaseMessaging.instance.subscribeToTopic(Constants.fcmTopicKey);
  }

  // 전체발송 구독취소
  static Future<void> unSubscribe() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(Constants.fcmTopicKey);
  }
}