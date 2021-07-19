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

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getNearPlaces();
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

    return new Container(
        child: MapboxMap(
      styleString: 'mapbox://styles/mapbox/streets-v8',
      accessToken: "",
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 14.4746,
      ),
    ));
  }
}
