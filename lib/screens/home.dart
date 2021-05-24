import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      String token = await storage.read(key: 'jwt');
      if (token == null) {
        await Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Laira",
              style: TextStyle(
                  color: Color(0xFF189AB4),
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            Text("Your travel starts here",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFb49818))),
          ],
        ),
        toolbarHeight: 80,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 13.0, top: 10),
              child: Text(
                "Near you",
                style: TextStyle(
                    color: Color(0xFF189AB4),
                    fontWeight: FontWeight.w600,
                    fontSize: 25),
              ),
            ),
            SizedBox(height: 10),
            PlacesList(),
            PlacesList(),
            PlacesList(),
            PlacesList(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Near you',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Trip planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social',
          ),
        ],
      ),
    );
  }
}

class PlacesList extends StatelessWidget {
  const PlacesList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
      child: Row(
        children: [
          PlaceCard(),
          PlaceCard(),
          PlaceCard(),
        ],
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          print('Card tapped.');
        },
        child: const SizedBox(
          width: 180,
          height: 220,
          child: Text('A card that can be tapped'),
        ),
      ),
    );
  }
}
