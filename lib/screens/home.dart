import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';

import 'package:http/http.dart' as http;

final storage = new FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String token;

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      token = await storage.read(key: 'jwt');
      if (token == null) {
        await Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  Future<List<Place>> getNearPlaces() async {
    final List<Place> places = [];
    final response = await http.get(
        Uri.http('192.168.1.67:3333', '/api/places/around'),
        headers: {'auth-token': token});
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      for (var i = 0; i < json.length; i++) {
        places.add(Place.parseFromJson(json[i]));
      }
    } else {
      if (response.statusCode == 401) {
        return await Navigator.pushReplacementNamed(context, "/login");
      }
      throw Exception('Failed to get http');
    }
    return places;
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
                  "Places for you",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
                ),
              ),
              PlacesList(
                name: "Near you",
                function: getNearPlaces(),
              ),
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
  final Future<List<Place>> function;
  const PlacesList({
    Key key,
    // @required this.places,
    this.name,
    this.function,
  }) : super(key: key);

  // final List<PlaceCard> places;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 13.0, top: 10, bottom: 5),
          child: Text(
            this.name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
            child: FutureBuilder<List<Place>>(
              future: function,
              initialData: [],
              builder:
                  (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
                List<Widget> children = [];
                if (snapshot.hasData) {
                  for (Place place in snapshot.data) {
                    children.add(PlaceCard(place: place));
                  }
                  return Row(children: children);
                } else {
                  return SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  );
                }
              },
            )),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({Key key, this.photo, this.onTap, this.width})
      : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({Key key, this.place}) : super(key: key);
  final Place place;

  @override
  Widget build(BuildContext context) {
    String tag = place.photoUrl + DateTime.now().microsecond.toString();
    return Container(
      child: Hero(
        tag: tag,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PlaceDetail(
                    place: place,
                    tag: tag
                  ))),
          child: Card(
            elevation: 0,
            child: SizedBox(
                width: 200,
                height: 300,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Image.network(
                          place.photoUrl,
                          fit: BoxFit.cover,
                          height: 120,
                          width: 200,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                place.address.getAddressOnUi(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 13),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              place.getRating(15),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 20,
                                  ),
                                  Text(place.walkTime())
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_bike,
                                    size: 20,
                                  ),
                                  Text(place.bikeTime())
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 20,
                                  ),
                                  Text(place.carTime())
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
      ),
    );
  }
}
