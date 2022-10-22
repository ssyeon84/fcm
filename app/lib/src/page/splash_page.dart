import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:app/src/common/constants.dart';
import 'package:app/src/controller/notification_controller.dart';
import 'package:app/src/page/permission_page.dart';
import 'package:app/src/page/webview_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final _controller = NotificationController.to;

  @override
  void initState() {
    super.initState();
    // 3초후 페이지 이동
    Timer(const Duration(seconds: 3), _navigationPage);
  }

  _navigationPage() async {
    // 최초 접근시 권한체크로 이동
    const secureStorage = FlutterSecureStorage();
    String permissionYn = await secureStorage.read(key: Constants.permissionYn) ?? 'N';

    print('### _navigationPage ${_controller.messageData}');

    // 푸시메세지가 있다면 해당 Url 을 셋팅해준다
    String strartUrl = _controller.defaultWebviewURL;
    if(_controller.messageData != null && _controller.messageData!.containsKey('url')) {
      strartUrl = _controller.messageData!['url'];
    }
    if(permissionYn == 'N') {
      Get.offAll(PermissionPage(url: strartUrl));
    } else {
      Get.offAll(WebviewPage(url: strartUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
               Text("FCM", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
