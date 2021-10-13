import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laira/composables/Places.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/utils/uses-api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';

// ignore: must_be_immutable
class Map extends StatefulWidget with UsesApi {
  Map({Key? key, this.onCirclePressed, this.onCameraMove, this.onCameraIdle})
      : super(key: key);

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final Function(Circle)? onCirclePressed;
  final Function? onCameraMove;
  final Function? onCameraIdle;

  static bool? disableUi = true;
  static MapboxMapController? mapBoxController;

  static void planRoute(args) {}

  void setCurrentPositon() async {
    LatLng newPositon = await _getUserLocation();
    mapBoxController!.animateCamera(
        await _getCameraPosition(mapBoxController!, newPositon, 11));
    mapBoxController!
        .updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
  }

  void moveToLatLon(LatLng latLng, {double zoom = 11}) async {
    _getCameraPosition(mapBoxController!, latLng, zoom)
        .then((animation) => mapBoxController!.animateCamera(animation));
  }

  static void moveToLatLonStatic(LatLng latLng, {double zoom = 11}) async {
    _getCameraPosition(mapBoxController!, latLng, zoom)
        .then((animation) => mapBoxController!.animateCamera(animation));
  }

  static Future<CameraUpdate> _getCameraPosition(
      MapboxMapController controller, LatLng target, double zoom) async {
    CameraPosition position = new CameraPosition(target: target, zoom: zoom);

    return CameraUpdate.newCameraPosition(position);
  }

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

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with UsesApi {
  final String? token = dotenv.env['MAPBOX_API_KEY'];
  final String style = 'mapbox://styles/mapbox/streets-v11';

  bool _wasCameraIdle = false;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      styleString: style,
      accessToken: token,
      myLocationEnabled: true,
      annotationOrder: <AnnotationType>[
        AnnotationType.fill,
        AnnotationType.line,
        AnnotationType.circle,
        AnnotationType.symbol,
      ],
      onCameraIdle: () => {widget.onCameraIdle!(), _wasCameraIdle = true},
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 18.0,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: () => {print('loaded essss')},
    );
  }

  void _onMapCreated(MapboxMapController controller) async {
    controller.onCircleTapped.add((Circle circle) {
      if (circle.data['showInfo']) {
        _wasCameraIdle = false;
        widget.onCirclePressed!(circle);
      }
    });

    controller.addListener(() {
      if (controller.isCameraMoving && _wasCameraIdle) {
        widget.onCameraMove!();
      }
    });

    List<Place> places = await Placess.getPlace();
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
            "place": place,
            "showInfo": true
          });

      // controller.addCircle(options)(SymbolOptions(
      //     iconImage: "pin", geometry: new LatLng(place.lat, place.lon)));
    }

    Map.mapBoxController = controller;
    widget.setCurrentPositon();
  }

  LatLng _initialPosition = LatLng(
    50.3485116,
    23.333414,
  );
}
