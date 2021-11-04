import 'package:flutter/material.dart';
import 'package:laira/screens/home.dart';
import 'package:laira/screens/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laira/screens/places/new.dart';
import 'package:laira/screens/register.dart';
import 'package:laira/utils/constant.dart';

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
        theme: ThemeData(primaryColor: Color(MAIN_COLOR_ALPHA)),
        home: Login(),
        routes: {
          '/login': (context) => Login(),
          '/new-place': (context) => NewPlace(),
          '/home': (context) => HomePage(),
          '/register': (context) => Register(),
        });
  }
}
