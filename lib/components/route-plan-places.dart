import 'package:flutter/material.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/selected-place.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';
import 'package:laira/utils/constant.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class RoutePlanPlaces extends StatelessWidget {
  const RoutePlanPlaces({
    Key? key,
    @required List<Place>? routePlaces,
  })  : _routePlaces = routePlaces,
        super(key: key);

  final List<Place>? _routePlaces;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: ListView.builder(
            itemCount: _routePlaces!.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) => InkWell(
                onTap: () => {
                      Map.moveToLatLonStatic(
                          new LatLng(_routePlaces!.elementAt(i).lon,
                              _routePlaces!.elementAt(i).lat),
                          zoom: 16)
                    },
                child: Container(
                    child: SelectedPlace(
                      selectedPlace: _routePlaces!.elementAt(i),
                    ),
                    margin: EdgeInsets.only(left: MARGIN_HOME_LAYOUT),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(RADIUS),
                      color: Colors.white,
                    )))),
      ),
    );
  }
}
