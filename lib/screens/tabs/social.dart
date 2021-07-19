import 'package:flutter/material.dart';

class Social extends StatefulWidget {
  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Center(
            child: new Icon(Icons.accessibility_new,
                size: 150.0, color: Colors.brown)));
  }
}
