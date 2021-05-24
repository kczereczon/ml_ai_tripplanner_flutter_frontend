import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:laira/screens/home.dart';
import 'package:progress_dialog/progress_dialog.dart';

final storage = new FlutterSecureStorage();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "";
  String password = "";
  String error = "";

  ProgressDialog pr;

  void _setError(String error) {
    setState(() {
      this.error = error;
    });
  }

  Future<http.Response> login() {
    return http.post(
      Uri.http('192.168.1.67:3333', '/api/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'email': this.email, 'password': this.password}),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return Scaffold(
        // backgroundColor: Color(0xFFEEEEEE),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Laira",
                          style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF189AB4))),
                      Text("Your travel starts here",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w200)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  onChanged: (email) => this.email = email,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (password) => this.password = password,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text("Forgot password?",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ))),
                SizedBox(height: 20),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child:
                        Text(this.error, style: TextStyle(color: Colors.red))),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      await pr.show();
                      try {
                        http.Response response = await this.login();
                        print(response.body);
                        Future.delayed(Duration(seconds: 1));
                        Map<String, dynamic> map = jsonDecode(response.body);
                        if (response.statusCode != 200) {
                          this._setError(map['error']);
                        } else {
                          await storage.write(key: 'jwt', value: map['token']);
                          await Navigator.pushReplacementNamed(context, "/home");
                        }
                      } catch (e) {
                        this._setError("Error occures " + e.toString());
                      } finally {
                        await pr.hide();
                      }
                    },
                    child: Text("Log in",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF189AB4),
                    ),
                  ),
                )
              ]),
        ));
  }
}
