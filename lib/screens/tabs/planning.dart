import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laira/utils/uses-api.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mapbox_gl/mapbox_gl.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:progress_dialog/progress_dialog.dart';

final storage = new FlutterSecureStorage();

class Planning extends StatefulWidget with UsesApi {
  const Planning({Key? key, this.mapController}) : super(key: key);

  final MapboxMapController? mapController;

  @override
  _PlanningState createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  List<RadioModel> _radioButtons = [];
  RadioModel? _selectedRadio;
  double _value = 20;
  double _time = 60;

  ProgressDialog? progressDialog;

  @override
  void initState() {
    super.initState();
    progressDialog = new ProgressDialog(context);

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

    Object body = jsonEncode(<String, dynamic>{
      "lat": position.latitude,
      "lon": position.longitude,
      "distance": (this._value * 1000),
      "type": this._selectedRadio!.name.toString()
    });

    return await widget.post('/api/places/find-route',
        context: context, body: body);
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
              "Trip planning",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            SizedBox(height: 10),
            Text(
              "Type of vehicle",
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
              "How for you want to go",
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
            Text(
              "How much time you have to spand",
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
                onPressed: () async {
                  await progressDialog!.show();
                  try {
                    http.Response response = await this._planRoute();
                    print(response.body);
                    Future.delayed(Duration(seconds: 1));
                    Map<String, dynamic> map = jsonDecode(response.body);

                    var result = null;

                    List<LatLng> latLngs = [];

                    for (List<dynamic> coordinate in map['geoJson']
                        ['coordinates']) {
                      latLngs.add(new LatLng(coordinate[1], coordinate[0]));
                    }

                    print(widget.mapController!.circles);
                    print(latLngs);

                    widget.mapController!.lines.clear();

                    await widget.mapController!.addLine(LineOptions(
                        lineWidth: 10,
                        lineColor: "#9fD799",
                        lineOpacity: 0.8,
                        geometry: latLngs));

                    widget.mapController!
                        .animateCamera(CameraUpdate.zoomTo(11));
                    Navigator.of(context).pop(result);
                  } catch (e) {
                    print(e.toString());
                  } finally {
                    await progressDialog!.hide();
                  }
                },
                child: Text("Lets find a trip!",
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
