import 'package:flutter/material.dart';
import 'package:laira/screens/home.dart';
import 'package:laira/screens/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(primaryColor: Color(0xFF189AB4)),
        home: HomePage(),
        routes: {
          '/login': (context) => Login(),
          // When navigating to the "/" route, build the FirstScreen widget.
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/home': (context) => HomePage(),
        });
  }
}
