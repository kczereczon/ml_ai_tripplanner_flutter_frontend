import 'package:flutter/material.dart';
import 'package:laira/layout/home.dart';
import 'package:laira/utils/uses-api.dart';

class HomePage extends StatefulWidget with UsesApi {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, UsesApi {
  Widget build(BuildContext context) {
    return new HomeLayout();
  }
}
