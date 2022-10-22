class Constants {

  // static string
  static const permissionYn = 'permissionYn'; // 권한동의여부
  static const fcmTopicKey = 'all'; // FCM topic (firebase topic 설정값 저장)

  // static function
  static bool isBlank(String? s) => s == null || s.trim().isEmpty;
  static bool isNotBlank(String? s) => !isBlank(s);
}