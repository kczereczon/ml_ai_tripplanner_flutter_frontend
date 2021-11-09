import 'package:flutter/material.dart';
import 'package:laira/screens/home.dart';
import 'package:laira/screens/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laira/screens/places/new.dart';
import 'package:laira/screens/register.dart';
import 'package:laira/utils/constant.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

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
        darkTheme: ThemeData(
            primaryColor: Color(DARKER_MAIN_COLOR_ALPHA),
            accentColor: Colors.grey[300],
            backgroundColor: Color(DARK_COLOR_ALPHA),
            hintColor: Colors.white38,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              labelStyle: TextStyle(color: Colors.grey[300]),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      width: 3, style: BorderStyle.solid, color: Colors.red)),
              fillColor: Color(DARKER_COLOR_ALPHA),
              focusColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  )),
            ),
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: Color(DARKER_MAIN_COLOR_ALPHA)),
            textTheme: TextTheme(
                subtitle1: TextStyle(color: Colors.grey[300]),
                headline6: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 35)),
            appBarTheme: AppBarTheme(
                backgroundColor: Color(DARK_COLOR_ALPHA),
                elevation: 0,
                iconTheme:
                    IconThemeData(color: Color(DARKER_MAIN_COLOR_ALPHA)))),
        theme: ThemeData(
            primaryColor: Color(MAIN_COLOR_ALPHA),
            accentColor: Colors.black,
            backgroundColor: Color(LIGHT_COLOR_ALPHA),
            hintColor: Colors.black38,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              labelStyle: TextStyle(color: Colors.black),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      width: 3, style: BorderStyle.solid, color: Colors.red)),
              fillColor: Colors.white,
              focusColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  )),
            ),
            textSelectionTheme:
                TextSelectionThemeData(cursorColor: Color(MAIN_COLOR_ALPHA)),
            textTheme: TextTheme(
                subtitle1: TextStyle(color: Colors.black),
                headline6: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 35)),
            appBarTheme: AppBarTheme(
                backgroundColor: Color(LIGHT_COLOR_ALPHA),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(MAIN_COLOR_ALPHA)))),
        home: Login(),
        routes: {
          '/login': (context) => Login(),
          '/new-place': (context) => NewPlace(),
          '/home': (context) => HomePage(),
          '/register': (context) => Register(),
        });
  }
}
