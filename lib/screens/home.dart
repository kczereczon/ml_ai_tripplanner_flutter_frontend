import 'package:flutter/material.dart';

import 'package:laira/screens/tabs/places.dart';
import 'package:laira/screens/tabs/planning.dart';
import 'package:laira/screens/tabs/social.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: new Material(
            color: Colors.white,
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(
                  icon: new Icon(
                Icons.place,
                color: Colors.black,
              )),
              new Tab(icon: new Icon(Icons.map_rounded, color: Colors.black)),
              new Tab(icon: new Icon(Icons.people, color: Colors.black))
            ])),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[new Places(), new Planning(), new Social()]));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBody: true,
  //     body: ,
  //     backgroundColor: Color(0xFFEEEEEE),
  //     bottomNavigationBar: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(30), topLeft: Radius.circular(30)),
  //           boxShadow: [
  //             BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
  //           ],
  //         ),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(30.0),
  //             topRight: Radius.circular(30.0),
  //           ),
  //           child: BottomNavigationBar(
  //             elevation: 0,
  //             currentIndex: _selectedIndex,
  //             onTap: _onItemTapped,
  //             selectedItemColor: Colors.black,
  //             items: [
  //               BottomNavigationBarItem(
  //                 icon: Icon(Icons.home),
  //                 label: 'Near you',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: Icon(Icons.map_rounded),
  //                 label: 'Trip planner',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: Icon(Icons.people),
  //                 label: 'Social',
  //               ),
  //             ],
  //           ),
  //         )),
  //   );
  // }
}
