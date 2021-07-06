import 'dart:convert';
import 'package:http/http.dart' as http;
import 'error.dart';

enum Method { get, post, put, delete }

final ApiService apiService = ApiService();
const baseUrl = 'http://report.bekhoe.vn';

class ApiService {
  factory ApiService() => _apiService;
  static final _apiService = ApiService._internal();

  ApiService._internal();

  Future<void> request({
    required String path,
    required Method method,
    Map<String, dynamic>? parameters,
    Map<String, String>? headers,
    Function(dynamic)? onSuccess,
    Function(String)? onFailure,
  }) async {
    parameters ??= {};
    headers ??= {};

    final accessToken = 'Bearer token';

    final _headers = {
      'authorization': accessToken,
    }..addAll(headers);

    print(baseUrl + path);
    // print('$_headers');

    try {
      http.Response res;

      final url = Uri.parse(baseUrl + path);

      switch (method) {
        case Method.get:
          res = await http.get(url, headers: _headers);
          break;
        case Method.post:
          res = await http.post(
            url,
            headers: _headers,
            body: parameters,
            encoding: utf8,
          );
          break;
        case Method.put:
          res = await http.put(
            url,
            headers: _headers,
            body: parameters,
            encoding: utf8,
          );
          break;
        case Method.delete:
          res = await http.delete(url, headers: _headers);
          break;
        default:
          res = await http.get(url, headers: _headers);
          break;
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body);


        onSuccess!(json);


        // final code = json['code'];
        // if (code == 0) {
        //   if (onSuccess != null) {
        //     onSuccess(json['data']);
        //   }
        // } else if (onFailure != null) {
        //   onFailure(serviceError(code) ?? json['message']);
        // }
      } else if (res.statusCode == 401) {
        forceLogout(message: 'Phiên đăng nhập đã hết hạn');
      } else {
        print('http status code: ${res.statusCode} \n ${res.body}');
        if (onFailure != null) {
          onFailure('Hệ thống đang bận, vui lòng thử lại sau');
        }
      }
    } catch (e) {
      print('api_service try catch: ${baseUrl + path}');
      if (onFailure != null) {
        onFailure('Có lỗi đã xảy ra, vui lòng thử lại');
      }
    }
  }

  void forceLogout({String? message}) {
    print('logout... $message');
  }
}
