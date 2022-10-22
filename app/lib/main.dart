import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:app/src/controller/notification_controller.dart';
import 'package:app/src/page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  Get.log("############################");
  Get.log("#      Initialize APP      #");
  Get.log("############################");

  WidgetsFlutterBinding.ensureInitialized();

  // config load
  await GlobalConfiguration().loadFromAsset("app_setting");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WebView App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: BindingsBuilder(() {
        // FCM init
        Get.put(NotificationController());
      }),
      locale: const Locale('ko'),
      home: const SplashPage(),
    );
  }
}
