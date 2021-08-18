import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laira/entities/place.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

final storage = new FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  MapboxMapController _mapboxMapController;
  Map<String, Circle> _circles = {};

  List<Place> _placeList;

  LatLng _initialPosition = LatLng(
    50.3485116,
    23.333414,
  );

  Future<LatLng> _getUserLocation() async {
    await _handlePermission();
    Position position = await _geolocatorPlatform.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return new LatLng(position.latitude, position.longitude);
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

  void _onMapCreated(MapboxMapController controller) async {
    // final ByteData bytes = await rootBundle.load("icons/location-pin.svg");
    // final Uint8List list = bytes.buffer.asUint8List();
    // await controller.addImage("pin", list);
    _setCurrentPositon(controller);
    controller.onCircleTapped.add((Circle circle) async => {
          controller.animateCamera(await _getCameraPosition(
              controller, new LatLng(circle.data['lon'], circle.data['lat'])))
        });

    List<Place> places = await _getPlaces();
    _placeList = places;
    print(_placeList);
    for (Place place in places) {
      controller.addCircle(
          CircleOptions(
              circleRadius: 10,
              circleColor: "#70D799",
              circleStrokeColor: "#FFF3F3",
              circleStrokeWidth: 2,
              geometry: new LatLng(place.lon, place.lat)),
          {
            "lat": place.lat,
            "lon": place.lon
          }).then((circle) => _circles.addAll({place.id: circle}));

      // controller.addCircle(options)(SymbolOptions(
      //     iconImage: "pin", geometry: new LatLng(place.lat, place.lon)));
      _mapboxMapController = controller;
    }
  }

  Future<CameraUpdate> _getCameraPosition(
      MapboxMapController controller, LatLng target) async {
    CameraPosition position = new CameraPosition(target: target, zoom: 18);

    return CameraUpdate.newCameraPosition(position);
  }

  void _setCurrentPositon(MapboxMapController controller) async {
    LatLng newPositon = await _getUserLocation();
    controller.animateCamera(await _getCameraPosition(controller, newPositon));
    controller.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
  }

  Future<List<Place>> _getPlaces() async {
    String token = await storage.read(key: 'jwt');
    if (token == null) {
      await Navigator.pushReplacementNamed(context, "/login");
    }
    final List<Place> places = [];
    final response = await http.get(
        Uri.http(dotenv.env['API_HOST_IP'], '/api/places/around'),
        headers: {'auth-token': token});
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      for (var i = 0; i < json.length; i++) {
        places.add(Place.parseFromJson(json[i]));
      }
    } else {
      throw Exception('Failed to get http');
    }
    return places;
  }

  Widget build(BuildContext context) {
    final String style = 'mapbox://styles/mapbox/streets-v11';

    return new Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_pin),
          onPressed: () => {_setCurrentPositon(_mapboxMapController)}),
      body: MapboxMap(
        styleString: style,
        accessToken: token,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10.0,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return new Scaffold(
  //       bottomNavigationBar: new Material(
  //           color: Colors.white,
  //           child: new TabBar(controller: controller, tabs: <Tab>[
  //             new Tab(
  //                 icon: new Icon(
  //               Icons.place,
  //               color: Colors.black,
  //             )),
  //             new Tab(icon: new Icon(Icons.map_rounded, color: Colors.black)),
  //             new Tab(icon: new Icon(Icons.people, color: Colors.black))
  //           ])),
  //       body: new TabBarView(
  //           physics: NeverScrollableScrollPhysics(),
  //           controller: controller,
  //           children: <Widget>[new Places(), new Planning(), new Social()]));
  // }

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