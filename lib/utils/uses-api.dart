import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storage = new FlutterSecureStorage();

class UsesApi {
  Future<http.Response> get(String url, {BuildContext? context}) async {
    try {
      final response = await http.get(Uri.http(dotenv.env['API_HOST_IP']!, url),
          headers: {'auth-token': await getToken(context)});

      if (response.statusCode == 401 && context != null) {
        await Navigator.pushReplacementNamed(context, "/login");
      }

      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<String> getToken(BuildContext? context) async {
    String? token = await storage.read(key: 'jwt');

    if (token == null && context != null) {
      await Navigator.pushReplacementNamed(context, "/login");
      return "";
    } else if (token == null && context == null) {
      return "";
    } else {
      return token!;
    }
  }

  void checkAuth(BuildContext? context, int statusCode) async {
    if (statusCode == 401 && context != null) {
      await Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<http.Response> post(String url,
      {BuildContext? context, Object? body}) async {
    try {
      final response = await http.post(
          Uri.http(dotenv.env['API_HOST_IP']!, url),
          headers: {'auth-token': await getToken(context)},
          body: body);

      checkAuth(context, response.statusCode);

      return response;
    } catch (e) {
      throw e;
    }
  }
}
