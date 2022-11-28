import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:app/src/common/constants.dart';
import 'package:app/src/page/permission_page.dart';
import 'package:app/src/page/webview_page.dart';
import 'package:global_configuration/global_configuration.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final String defaultWebviewURL = GlobalConfiguration().getValue("defaultWebviewURL");

  @override
  void initState() {
    super.initState();
    // 1초후 페이지 이동
    Timer(const Duration(seconds: 1), _navigationPage);
  }

  _navigationPage() async {
    // 최초 접근시 권한체크로 이동
    const secureStorage = FlutterSecureStorage();
    String permissionYn = await secureStorage.read(key: Constants.permissionYn) ?? 'N';

    // 푸시메세지가 있다면 해당 Url 을 셋팅해준다
    String strartUrl = defaultWebviewURL;
    if (permissionYn == 'N') {
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
