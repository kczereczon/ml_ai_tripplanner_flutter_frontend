import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laira/entities/place.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

final storage = new FlutterSecureStorage();

class Planning extends StatefulWidget {
  @override
  _PlanningState createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  LatLng _initialPosition;
  List<Place> _placeList;
  List<RadioModel> _radioButtons = [];
  RadioModel _selectedRadio;
  double _value = 20;
  double _time = 60;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getNearPlaces();

    _radioButtons.add(new RadioModel(false, Icons.directions_car, "car"));
    _radioButtons.add(new RadioModel(false, Icons.directions_bike, "bike"));
    _radioButtons.add(new RadioModel(true, Icons.directions_walk, "walk"));

    _selectedRadio = _radioButtons[2];
  }

  void _getUserLocation() async {
    await _handlePermission();
    Position position = await _geolocatorPlatform.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }
    return true;
  }

  void _getNearPlaces() async {
    String token = await storage.read(key: 'jwt');
    if (token == null) {
      await Navigator.pushReplacementNamed(context, "/login");
    }
    final List<Place> places = [];
    final response = await http.get(
        Uri.http('192.168.1.86:3333', '/api/places/around'),
        headers: {'auth-token': token});
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      for (var i = 0; i < json.length; i++) {
        places.add(Place.parseFromJson(json[i]));
      }
    } else {
      throw Exception('Failed to get http');
    }
    _placeList = places;
  }

  @override
  Widget build(BuildContext context) {
    MapboxMapController mapController;

    void _onMapCreated(MapboxMapController controller) {
      mapController = controller;
      for (Place place in _placeList) {
        mapController.addSymbol(
          SymbolOptions(
              geometry: LatLng(place.lon, place.lat),
              iconImage: 'marker-15',
              textField: place.name,
              textSize: 15,
              iconColor: "#00FFFF",
              textOffset: Offset(0, 2)),
        );
      }
    }

    String _minsToString(double mins) {
      int roundedMins = mins.toInt();

      int hours = roundedMins ~/ 60;
      int trueMins = roundedMins - hours * 60;

      return hours.toString() + "h " + trueMins.toString() + "m";
    }

    return new Container(
      child: Column(
        children: [
          Container(
              height: 300,
              child: MapboxMap(
                styleString: 'mapbox://styles/mapbox/streets-v8',
                accessToken: "",
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14.4746,
                ),
              )),
          Container(
              height: 420,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trip planning",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Type of vehicle",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              //highlightColor: Colors.red,
                              splashColor: Colors.white70,
                              onTap: () {
                                setState(() {
                                  _radioButtons.forEach(
                                      (element) => element.isSelected = false);
                                  _radioButtons[0].isSelected = true;
                                });
                              },
                              child: new RadioItem(_radioButtons[0]),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              //highlightColor: Colors.red,
                              splashColor: Colors.white70,
                              onTap: () {
                                setState(() {
                                  _radioButtons.forEach(
                                      (element) => element.isSelected = false);
                                  _radioButtons[1].isSelected = true;
                                });
                              },
                              child: new RadioItem(_radioButtons[1]),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              //highlightColor: Colors.red,
                              splashColor: Colors.white70,
                              onTap: () {
                                setState(() {
                                  _radioButtons.forEach(
                                      (element) => element.isSelected = false);
                                  _radioButtons[2].isSelected = true;
                                });
                              },
                              child: new RadioItem(_radioButtons[2]),
                            )
                          ]),
                      SizedBox(height: 10),
                      Text(
                        "How for you want to go",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                                thumbColor: Colors.white,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10)),
                            child: Slider(
                              max: 150,
                              value: _value,
                              onChanged: (val) {
                                _value = val;
                                setState(() {});
                              },
                            ),
                          ),
                          Text(_value.toInt().toString() + " km")
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "How much time you have to spand",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20),
                      ),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                                thumbColor: Colors.white,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10)),
                            child: Slider(
                              max: 180,
                              value: _time,
                              onChanged: (val) {
                                _time = val;
                                setState(() {});
                              },
                            ),
                          ),
                          Text(_minsToString(_time))
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: TextButton(
                          onPressed: () async {},
                          child: Text("Lets find a trip!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      )
                    ]),
              ))
        ],
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: _item.isSelected ? Colors.blueAccent : Colors.white),
        child: Icon(
          _item.icon,
          color: _item.isSelected ? Colors.white : Colors.black,
        ));
  }
}

class RadioModel {
  bool isSelected;
  final IconData icon;
  final String name;

  RadioModel(this.isSelected, this.icon, this.name);
}
