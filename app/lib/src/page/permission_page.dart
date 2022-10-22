import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:app/src/common/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/src/page/webview_page.dart';

class PermissionPage extends StatelessWidget {
  final String url;
  const PermissionPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 32, right: 32, top: 100, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('앱 권한 동의 안내', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xff00000a), fontFamily: 'AppleSDGothicNeo',  fontStyle: FontStyle.normal)),
                      const SizedBox(height: 10),
                      const Text('선택 접근권한은 허용하지 않으셔도 이용이 가능하나,\n해당권한이 필요한 기능은 사용이 제한 될 수 있습니다.',textAlign: TextAlign.left, style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w300)),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Color.fromRGBO(0, 0, 10, 0.1)),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              permissionGuide(
                                  imgPath: 'assets/images/icon-32-camera.svg',
                                  mainTxt: '카메라 (선택)',
                                  subTxt : '사진 촬영'
                              ),
                              permissionGuide(
                                  imgPath: 'assets/images/icon-32-folder.svg',
                                  mainTxt: '저장공간 (선택)',
                                  subTxt : '이미지 및 커뮤니티 사진 첨부'
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
            InkWell(
              onTap: _checkAgree,
              child: Container(
                height: 56,
                color: const Color(0xFF492cea),
                child: const Center(
                  child: Text('확인', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _checkAgree() async {
    const secureStorage = FlutterSecureStorage();
    // 카메라 접근권한 체크
    await Permission.camera.request();
    //  파일 접근권한 체크
    if(Platform.isAndroid) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
    }
    secureStorage.write(key: Constants.permissionYn, value: 'Y');
    Get.offAll(WebviewPage(url: url));
  }

  Widget permissionGuide({required String imgPath, String? mainTxt, String? subTxt}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20, right: 20),
          child: SvgPicture.asset(imgPath, width: 30),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainTxt ?? '', style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(subTxt ?? '', style: const TextStyle(color: Color.fromRGBO(0, 0, 10, 0.5),fontSize: 14,fontWeight: FontWeight.w300)),
          ],
        )
      ],
    );
  }
}
