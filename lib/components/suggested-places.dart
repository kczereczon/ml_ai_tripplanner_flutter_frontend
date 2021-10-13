import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laira/components/suggested-place.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/utils/uses-api.dart';

class SuggestedPlaces extends StatelessWidget {
  SuggestedPlaces({
    Key? key,
    @required Function(Place)? onTap,
  })  : _onTap = onTap,
        super(key: key);

  final Function(Place)? _onTap;

  Future<List<Place>> _getSuggestedPlaces() async {
    final List<Place> places = [];
    try {
      Position position =
          await GeolocatorPlatform.instance.getCurrentPosition();
      await UsesApi.post("/api/user/location",
          body: {"lat": position.latitude, "lon": position.longitude});
      final response = await UsesApi.get("/api/places/suggested");
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        for (var i = 0; i < json.length; i++) {
          places.add(Place.parseFromJson(json[i]));
        }
      } else {
        throw Exception('Failed to get http');
      }
    } catch (e) {}
    return places;
  }

  @override
  Widget build(BuildContext context) {
    // SmallPlace(place: , onTap: _onTap),
    return Positioned(
      bottom: 240,
      child: Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
              future: _getSuggestedPlaces(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
                if (snapshot.hasData) {
                  List<SmallPlace> places = [];
                  for (Place place in snapshot.data!) {
                    places.add(new SmallPlace(
                        place: place, onTap: _onTap, first: places.isEmpty));
                  }
                  return ListView(
                      scrollDirection: Axis.horizontal, children: places);
                } else {
                  return Container();
                }
              })),
    );
  }
}
