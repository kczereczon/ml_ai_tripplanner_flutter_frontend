import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laira/entities/place.dart';
import 'package:laira/utils/uses-api.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mapbox_gl/mapbox_gl.dart';
// ignore: import_of_legacy_library_into_null_safe

final storage = new FlutterSecureStorage();

class Planning extends StatefulWidget {
  const Planning({Key? key, this.mapController, this.onMapPlanned})
      : super(key: key);

  final MapboxMapController? mapController;
  final Function(List<Place>, List<LatLng>)? onMapPlanned;

  @override
  _PlanningState createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  List<RadioModel> _radioButtons = [];
  RadioModel? _selectedRadio;
  double _value = 20;
  double _time = 60;

  @override
  void initState() {
    super.initState();

    _radioButtons.add(new RadioModel(false, Icons.directions_car, "driving"));
    _radioButtons.add(new RadioModel(false, Icons.directions_bike, "cycling"));
    _radioButtons.add(new RadioModel(true, Icons.directions_walk, "walking"));

    _selectedRadio = _radioButtons[2];
  }

  Future<Position> _getUserLocation() async {
    await _handlePermission();
    Position position = await _geolocatorPlatform.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
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

  Future<http.Response> _planRoute() async {
    Position position = await _getUserLocation();

    Object body = <String, dynamic>{
      "lat": position.latitude,
      "lon": position.longitude,
      "distance": (this._value * 1000),
      "type": this._selectedRadio!.name.toString()
    };

    return UsesApi.post('/api/places/find-route', context: context, body: body);
  }

  @override
  Widget build(BuildContext context) {
    String _minsToString(double mins) {
      int roundedMins = mins.toInt();

      int hours = roundedMins ~/ 60;
      int trueMins = roundedMins - hours * 60;

      return hours.toString() + "h " + trueMins.toString() + "m";
    }

    return new Container(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Planowanie wycieczki",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            SizedBox(height: 10),
            Text(
              "Czym będziesz się poruszał",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                //highlightColor: Colors.red,
                splashColor: Colors.white70,
                onTap: () {
                  setState(() {
                    _radioButtons
                        .forEach((element) => element.isSelected = false);
                    _radioButtons[0].isSelected = true;
                    _selectedRadio = _radioButtons[0];
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
                    _radioButtons
                        .forEach((element) => element.isSelected = false);
                    _radioButtons[1].isSelected = true;
                    _selectedRadio = _radioButtons[1];
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
                    _radioButtons
                        .forEach((element) => element.isSelected = false);
                    _radioButtons[2].isSelected = true;
                    _selectedRadio = _radioButtons[2];
                  });
                },
                child: new RadioItem(_radioButtons[2]),
              )
            ]),
            SizedBox(height: 10),
            Text(
              "Maksymalny dystans",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                      thumbColor: Colors.white,
                      activeTrackColor: Color(0xFF70D799),
                      inactiveTrackColor: Color(0x5570D799),
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10)),
                  child: Slider(
                    min: 1,
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
            // Text(
            //   "Jak dużo czasu chcesz poświecić (",
            //   style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            // ),
            // Column(
            //   children: [
            //     SliderTheme(
            //       data: SliderThemeData(
            //           thumbColor: Colors.white,
            //           activeTrackColor: Color(0xFF70D799),
            //           inactiveTrackColor: Color(0x5570D799),
            //           thumbShape:
            //               RoundSliderThumbShape(enabledThumbRadius: 10)),
            //       child: Slider(
            //         max: 180,
            //         value: _time,
            //         onChanged: (val) {
            //           _time = val;
            //           setState(() {});
            //         },
            //       ),
            //     ),
            //     Text(_minsToString(_time))
            //   ],
            // ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: TextButton(
                onPressed: () async {
                  try {
                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.loading,
                        text: "Szukam nalepszej trasy... 🧐",
                        barrierDismissible: false);

                    http.Response response = await this._planRoute();
                    Map<String, dynamic> map = jsonDecode(response.body);

                    widget.mapController!.clearCircles();

                    List<Place> places = [];

                    for (var i = 0;
                        i < map['response']['waypoints'].length;
                        i++) {
                      places.add(Place.parseFromJson(
                          map['response']['waypoints'][i]['place']));
                    }

                    var result = null;

                    List<LatLng> latLngs = [];

                    for (List<dynamic> coordinate in map['geoJson']
                        ['coordinates']) {
                      latLngs.add(new LatLng(coordinate[1], coordinate[0]));
                    }

                    for (List<dynamic> coordinate in map['geoJson']
                        ['coordinates']) {
                      latLngs.add(new LatLng(coordinate[1], coordinate[0]));
                    }

                    widget.onMapPlanned!(places, latLngs);

                    Navigator.pop(context);
                    Navigator.pop(context, 'success');
                  } catch (e) {
                    print("Error: " + e.toString());
                    Navigator.pop(context);
                    Navigator.pop(context, 'error');
                  } finally {}
                },
                child: Text("Wyznacz trasę 🚀",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300)),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF70D799),
                ),
              ),
            )
          ]),
    ));
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
            color: _item.isSelected ? Color(0xFF70D799) : Colors.white),
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
