import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/src/common/constants.dart';
import 'package:app/src/controller/notification_controller.dart';
import 'package:app/src/service/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final imageController = TextEditingController();

  final service = NotificationSerivce();
  final controller = NotificationController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메세지전송 테스트 페이지"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "제목"),
                      ),
                      TextField(
                        controller: bodyController,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: "내용"),
                      ),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(labelText: "이미지 URL"),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          await service.sendMessage('topic', target: Constants.fcmTopicKey, title: titleController.text, body: bodyController.text, imageUrl: imageController.text);
                        },
                        child: Container(
                          height: 56,
                          color: const Color(0xFF492cea),
                          child: const Center(
                            child: Text('전체발송', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          await service.sendMessage('token', target: controller.deviceToken, title: titleController.text, body: bodyController.text, imageUrl: imageController.text);
                        },
                        child: Container(
                          height: 56,
                          color: const Color(0xFF492cea),
                          child: const Center(
                            child: Text('나에게전송', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
