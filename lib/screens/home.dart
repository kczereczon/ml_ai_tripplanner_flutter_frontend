import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laira/screens/places/detail.dart';

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
      extendBody: true,
      body: Container(
        padding: EdgeInsets.only(bottom: 30),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 13.0, top: 40),
                child: Text(
                  "Near you",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
                ),
              ),
              PlacesList(),
              PlacesList(),
              PlacesList(),
              PlacesList(),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: BottomNavigationBar(
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.black,
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
          )),
    );
  }
}

class PlacesList extends StatelessWidget {
  const PlacesList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 13.0, top: 10, bottom: 5),
          child: Text(
            "New in your neighbour",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
          child: Row(
            children: [
              PlaceCard(),
              PlaceCard(),
              PlaceCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PlaceDetail())),
              child: Card(
          elevation: 0,
          child: SizedBox(
              width: 200,
              height: 300,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Image.network(
                    "https://tropter.com/uploads/uploads/images/ce/b8/1df885b1d3b8bf8e6a764c7e023a54b722a7/letni_palac_lubomirskich_000_big.jpg?t=20200122105218",
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Atraction",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          "ul. Lwowska 28, 37-610 Lipsko",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 15,
                            ),
                            Icon(
                              Icons.star,
                              size: 15,
                            ),
                            Icon(
                              Icons.star,
                              size: 15,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              size: 20,
                            ),
                            Text("1h 30m")
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_bike,
                              size: 20,
                            ),
                            Text("1h 30m")
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 20,
                            ),
                            Text("1h 30m")
                          ],
                        )
                      ]),
                )
              ])),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
