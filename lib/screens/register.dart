import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String name = "";
  String email = "";
  String password = "";
  String repassword = "";

  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;

  String _nameErrorMessage = "";
  String _emailErrorMessage = "";
  String _passwordErrorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color(0xFFEEEEEE),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Laira",
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Color(MAIN_COLOR_ALPHA))),
                    Text("Rejestracja",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w200)),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                onChanged: (name) => this.name = name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Nazwa",
                  errorText: _nameError ? this._nameErrorMessage : null,
                  prefixIcon:
                      Icon(Icons.person, color: Color(MAIN_COLOR_ALPHA)),
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
                onChanged: (email) => this.email = email,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Email",
                  errorText: _emailError ? this._emailErrorMessage : null,
                  prefixIcon: Icon(Icons.mail, color: Color(MAIN_COLOR_ALPHA)),
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
                  hintText: "Hasło",
                  errorText: _passwordError ? this._passwordErrorMessage : null,
                  prefixIcon: Icon(Icons.lock, color: Color(MAIN_COLOR_ALPHA)),
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
                onChanged: (repassword) => this.repassword = repassword,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Powtórz hasło",
                  prefixIcon: Icon(Icons.lock, color: Color(MAIN_COLOR_ALPHA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    try {
                      setState(() => {
                            this._nameError = false,
                            this._emailError = false,
                            this._passwordError = false,
                          });

                      if (this.name.isEmpty) {
                        setState(() => {
                              this._nameError = true,
                              this._nameErrorMessage =
                                  "Nazwa użytkownika musi być uzupełniona."
                            });
                        return;
                      }
                      if (this.email.isEmpty) {
                        setState(() => {
                              this._emailError = true,
                              this._emailErrorMessage =
                                  "Emails musi być uzupełniony."
                            });
                        return;
                      }
                      if (this.password.isEmpty) {
                        setState(() => {
                              this._passwordError = true,
                              this._passwordErrorMessage =
                                  "Hasło nie może być puste."
                            });
                        return;
                      }

                      if (this.password != this.repassword) {
                        setState(() => {
                              this._passwordError = true,
                              this._passwordErrorMessage =
                                  "Hasła nie są takie same."
                            });
                        return;
                      }

                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.loading,
                      );

                      Response response =
                          await UsesApi.post('/api/user/register', body: {
                        "name": this.name,
                        "password": this.password,
                        "email": this.email,
                      });

                      Map<String, dynamic> map = jsonDecode(response.body);

                      if (response.statusCode == 400) {
                        if (map['field'] == "username") {
                          setState(() => {
                                this._nameError = true,
                                this._nameErrorMessage =
                                    "Taki użytkownik już istnieje."
                              });
                          return;
                        }

                        if (map['field'] == "email") {
                          setState(() => {
                                this._emailError = true,
                                this._emailErrorMessage =
                                    "Taki email jest już używany."
                              });
                          return;
                        }
                      }
                      await Navigator.pushReplacementNamed(context, "/login");
                    } catch (e) {
                      // this._setError("Error occures " + e.toString());
                    } finally {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  child: Text("Utwórz konto 😉",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300)),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(MAIN_COLOR_ALPHA),
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await Navigator.pushReplacementNamed(context, "/login");
                      } catch (e) {} finally {}
                    },
                    child: Text("Wróć do logowania",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(MAIN_COLOR_ALPHA),
                    ),
                  ))
            ])));
  }
}
