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
        appBar: AppBar(
            elevation: 0,
            leading: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                icon: Icon(Icons.arrow_back_ios))),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Laira",
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                    Text("Rejestracja!",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                            color: Theme.of(context).accentColor)),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                onChanged: (name) => this.name = name,
                decoration: InputDecoration(
                  hintText: "Nazwa",
                  errorText: _nameError ? this._nameErrorMessage : null,
                  prefixIcon:
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (email) => this.email = email,
                decoration: InputDecoration(
                  hintText: "Email",
                  errorText: _emailError ? this._emailErrorMessage : null,
                  prefixIcon:
                      Icon(Icons.mail, color: Theme.of(context).primaryColor),
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
                  hintText: "Hasło",
                  errorText: _passwordError ? this._passwordErrorMessage : null,
                  prefixIcon:
                      Icon(Icons.lock, color: Theme.of(context).primaryColor),
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
                  hintText: "Powtórz hasło",
                  prefixIcon:
                      Icon(Icons.lock, color: Theme.of(context).primaryColor),
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
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w300)),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 5),
            ])));
  }
}
