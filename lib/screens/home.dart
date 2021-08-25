import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laira/components/selected-place.dart';
import 'package:laira/components/sugessted-places.dart';
import 'package:laira/components/suggested-place.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';
import 'package:laira/screens/tabs/planning.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class HomePage extends StatefulWidget with UsesApi {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  static MapboxMapController? _mapboxMapController;
  Map<String, Circle> _circles = {};

  bool _selectedPlaceVisable = false;
  bool _wasCameraIdle = true;

  Place? _selectedPlace = null;
  Widget? _selectedPlaceUi = null;
  List<Widget> _additionalStackWidgets = [];

  List<Place>? _placeList;

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

  void _onSmallPlaceClicked(place) {
    _additionalStackWidgets.clear();
    _wasCameraIdle = false;
    _selectedPlace = place;
    setState(() => {
          _additionalStackWidgets.add(
            new SelectedPlace(selectedPlace: place),
          ),
          _additionalStackWidgets
              .add(new SuggestedPlaces(onTap: _onSmallPlaceClicked))
        });
    _getCameraPosition(_mapboxMapController!, new LatLng(place.lon, place.lat))
        .then((animation) => _mapboxMapController!.animateCamera(animation));
  }

  void _onMapCreated(MapboxMapController controller) async {
    _setCurrentPositon(controller);
    controller.onCircleTapped.add((Circle circle) async => {
          setState(() => {
                _additionalStackWidgets.clear(),
                _wasCameraIdle = false,
                _selectedPlace = circle.data['place'],
                _additionalStackWidgets.add(
                  new SelectedPlace(
                    selectedPlace: _selectedPlace!,
                  ),
                ),
                _additionalStackWidgets.add(
                  new SuggestedPlaces(onTap: _onSmallPlaceClicked),
                )
              }),
          controller.animateCamera(await _getCameraPosition(
              controller, new LatLng(circle.data['lon'], circle.data['lat'])))
        });

    controller.addListener(() {
      if (this._additionalStackWidgets.length > 0 &&
          controller.isCameraMoving &&
          _wasCameraIdle) {
        setState(() => {_additionalStackWidgets.clear()});
      }
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
            "lon": place.lon,
            "address": place.address.getAddressOnUi(),
            "name": place.name,
            "image": place.photoUrl,
            "place": place
          }).then((circle) => _circles.addAll({place.id: circle}));

      // controller.addCircle(options)(SymbolOptions(
      //     iconImage: "pin", geometry: new LatLng(place.lat, place.lon)));
      _mapboxMapController = controller;
    }
  }

  Future<CameraUpdate> _getCameraPosition(
      MapboxMapController controller, LatLng target) async {
    CameraPosition position = new CameraPosition(target: target, zoom: 11);

    return CameraUpdate.newCameraPosition(position);
  }

  void _setCurrentPositon(MapboxMapController controller) async {
    LatLng newPositon = await _getUserLocation();
    controller.animateCamera(await _getCameraPosition(controller, newPositon));
    controller.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
  }

  Future<List<Place>> _getPlaces() async {
    final response = await widget.get("/api/places/all", context: context);

    final List<Place> places = [];

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
    final String? token = dotenv.env['MAPBOX_API_KEY'];
    final String style = 'mapbox://styles/mapbox/streets-v11';

    return new Scaffold(
        body: Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        MapboxMap(
          styleString: style,
          accessToken: token,
          myLocationEnabled: true,
          onCameraIdle: () => _wasCameraIdle = true,
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 18.0,
          ),
          onMapCreated: _onMapCreated,
        ),
        ..._additionalStackWidgets,
        Positioned(
            bottom: 50,
            left: 15,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 90,
              decoration: BoxDecoration(),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).restorablePush(_dialogBuilder);
                },
                child: Text("Wyznacz trasę",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300)),
                style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF70D799),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RADIUS))),
              ),
            )),
        Positioned(
          bottom: 50,
          right: 15,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(),
            child: FloatingActionButton(
                child: Icon(Icons.location_pin, color: Color(0xFF70D799)),
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RADIUS)),
                onPressed: () => {_setCurrentPositon(_mapboxMapController!)}),
          ),
        )
      ],
    ));
  }

  static Route<Object?> _dialogBuilder(
      BuildContext context, Object? arguments) {
    return DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Planning(mapController: _mapboxMapController),
                ],
              ),
            ));
    ;
  }
}
