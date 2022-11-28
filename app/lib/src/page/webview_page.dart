import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:app/src/controller/notification_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  final String url;
  const WebviewPage({Key? key,required this.url}) : super(key: key);

  @override
  State<WebviewPage> createState() => _WebviewState();
}

class _WebviewState extends State<WebviewPage> {

  final notiController = NotificationController.to;

  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopAction,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
              children: [
                WebView(
                  initialUrl: widget.url,
                  onWebViewCreated: (WebViewController controller) {
                    _webViewController = controller;
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                ),
                // 종료버튼
                Positioned(
                    right: 20,
                    bottom: 50,
                    child: InkWell(
                      onTap: exitConfirm,
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: SvgPicture.asset(
                              'assets/images/icon-28-close.svg',
                              width: 28,
                              height: 28)),
                    ))
              ],
            )
        ),
      ),
    );
  }

  // 앱 종료 Confirm
  Future<void> exitConfirm() {
    return showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
              title: const Text('종료하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => SystemNavigator.pop(), child: const Text('네')),
                TextButton(onPressed: Get.back, child: const Text('아니요'))
              ],
            ));
  }

  // android 뒤로가기 버튼 선택시 webview history 체크
  Future<bool> willPopAction() async {
    if (await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
      return Future.value(false);
    } else {
      exitConfirm();
      return Future.value(true);
    }
  }
}
