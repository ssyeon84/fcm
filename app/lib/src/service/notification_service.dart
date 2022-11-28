import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/src/service/api_service.dart';
import 'package:get/get.dart';

class NotificationSerivce {

  // 현재 사용 안함
  Future<http.Response> sendMessage(String path, {String? target, String? title, String? body, String? imageUrl}) async {
    Map<String, dynamic> params = {
      "target" : target,
      "title" : title,
      "body": body,
      "imageUrl" : imageUrl
    };
    http.Response response = await ApiService.post("/fcm/send/${path}", body: params);
    if(response.statusCode == HttpStatus.ok) {
      // successConfirm('전송완료');
    } else {
      successConfirm('전송실패');
    }
    return response;
  }

  successConfirm(String msg) {
    showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text(msg),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('확인'))
          ],
        )
    );
  }

}