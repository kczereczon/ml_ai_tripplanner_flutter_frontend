import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

final storage = new FlutterSecureStorage();

class UsesApi {
  static Future<http.Response> get(String url,
      {BuildContext? context, Map<String, dynamic>? query}) async {
    try {
      final response = await http.get(
          Uri.http(dotenv.env['API_HOST_IP']!, url, query),
          headers: {'auth-token': await getToken(context)});

      if (response.statusCode == 401 && context != null) {
        await Navigator.pushReplacementNamed(context, "/login");
      }

      return response;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> getToken(BuildContext? context) async {
    String? token = await storage.read(key: 'jwtLaira');

    if (token == null && context != null) {
      await Navigator.pushReplacementNamed(context, "/login");
      return "";
    } else if (token == null && context == null) {
      return "";
    } else {
      return token!;
    }
  }

  static void checkAuth(BuildContext? context, int statusCode) async {
    if (statusCode == 401 && context != null) {
      await Navigator.pushReplacementNamed(context, "/login");
    }
  }

  static Future<http.Response> post(String url,
      {BuildContext? context,
      Object? body,
      Map<String, String> additionalHeaders = const {}}) async {
    try {
      Map<String, String> headers = {
        'auth-token': await getToken(context),
        'content-type': 'application/json'
      };

      headers.addAll(additionalHeaders);

      final response = await http.post(
          Uri.http(dotenv.env['API_HOST_IP']!, url),
          headers: headers,
          body: jsonEncode(body),
          encoding: Encoding.getByName("utf-8"));

      checkAuth(context, response.statusCode);

      return response;
    } catch (e) {
      throw e;
    }
  }

  static Future<http.Response?> multiPartPost(String url, File image,
      {BuildContext? context,
      Map<String, String>? body,
      Map<String, String> additionalHeaders = const {}}) async {
    var uri = Uri.http(dotenv.env['API_HOST_IP']!, url);
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', uri);
    imageUploadRequest.headers.addAll({'auth-token': await getToken(context)});
    body!.forEach((key, value) {
      imageUploadRequest.fields[key] = value;
    });

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);

    // add headers if needed
    //imageUploadRequest.headers.addAll(<some-headers>);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      checkAuth(context, response.statusCode);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
