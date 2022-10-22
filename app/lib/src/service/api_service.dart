import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:app/src/common/constants.dart';

class ApiService {

  static Map<String, String> headers = HashMap();
  static String apiUrl = GlobalConfiguration().getValue("apiUrl");

  static Map<String, String> _setDefaultHeader() {
    headers[HttpHeaders.contentTypeHeader] = "application/json";
    return headers;
  }

  // HTTP GET
  static Future<http.Response> get(String path, { Map<String, dynamic>? params }) async {
    var random = Random.secure();
    var ranValue = base64UrlEncode(List<int>.generate(5, (index) => random.nextInt(255)));
    convertParams(params);
    var uri = Uri.parse(apiUrl + path);
    uri = uri.replace(queryParameters: params);
    http.Response response = await http.get(uri, headers: _setDefaultHeader());
    Get.log('# [ ${ranValue} ] httpGet path: ${apiUrl}${path}, response status: ${response.statusCode}');

    return Future.value(response);
  }

  // HTTP POST
  static Future<http.Response> post(String path, { Map<String, dynamic>? params, dynamic? body }) async {
    var uri = Uri.parse(apiUrl + path);
    convertParams(params);
    uri = uri.replace(queryParameters: params);
    http.Response response = await http.post(uri, headers: _setDefaultHeader(), body: json.encode(body));
    Get.log('# httpPost path: ${uri}, params: ${params}, body: ${body}, response status: ${response.statusCode}');

    return Future.value(response);
  }

  //  query param 에는 모두 string 으로 변환
  static convertParams(Map<String, dynamic>? params) {
    if(params != null && params.isNotEmpty){
      params.forEach((key, value) {
        if(value != null){
          String strVal = value.toString();
          if(Constants.isNotBlank(strVal)){
            params[key] = strVal;
          }
        }
      });
    }
  }

}