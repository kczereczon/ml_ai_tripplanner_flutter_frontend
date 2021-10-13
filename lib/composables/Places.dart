import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/utils/uses-api.dart';

class Placess {
  static List<Place> places = [];

  static Future<List<Place>> getPlace() async {
    Position position = await GeolocatorPlatform.instance.getCurrentPosition();
    await UsesApi.post("/api/user/location",
        body: {"lat": position.latitude, "lon": position.longitude});

    final response = await UsesApi.get("/api/places/all");

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
}
