import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            leading: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                icon: Icon(Icons.arrow_back_ios))),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextButton(
                  onPressed: () async {
                    await storage.delete(key: 'jwtLaira');
                    await Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Theme.of(context).accentColor,
                      ),
                      SizedBox(width: 20),
                      Text("Wyloguj się",
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[300],
                  ))
            ],
          ),
        ));
  }
}
