import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laira/components/selected-place.dart';
import 'package:laira/components/suggested-places.dart';
import 'package:laira/components/suggested-place.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/layout/home.dart';
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
  // void _onSmallPlaceClicked(place) {
  //   _additionalStackWidgets.clear();
  //   _wasCameraIdle = false;
  //   _selectedPlace = place;
  //   setState(() => {
  //         _additionalStackWidgets.add(
  //           new SelectedPlace(selectedPlace: place),
  //         ),
  //         _additionalStackWidgets
  //             .add(new SuggestedPlaces(onTap: _onSmallPlaceClicked))
  //       });
  //   _getCameraPosition(_mapboxMapController!, new LatLng(place.lon, place.lat))
  //       .then((animation) => _mapboxMapController!.animateCamera(animation));
  // }

  Widget build(BuildContext context) {
    return new HomeLayout();
  }
}
