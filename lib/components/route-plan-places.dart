import 'package:flutter/material.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/selected-place.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';
import 'package:laira/utils/constant.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class RoutePlanPlaces extends StatefulWidget {
  const RoutePlanPlaces({
    Key? key,
    @required List<Place>? routePlaces,
  })  : _routePlaces = routePlaces,
        super(key: key);

  final List<Place>? _routePlaces;

  @override
  _RoutePlanPlacesState createState() => _RoutePlanPlacesState();
}

class _RoutePlanPlacesState extends State<RoutePlanPlaces> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 50,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: PageView.builder(
              itemCount: widget._routePlaces!.length,
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 0.8),
              onPageChanged: (int index) => setState(() => {
                    _index = index,
                    Map.disableUi = false,
                    Map.mapBoxController!.updateMyLocationTrackingMode(
                        MyLocationTrackingMode.None),
                    Map.putHighlightCircle(
                        widget._routePlaces!.elementAt(index).lat,
                        widget._routePlaces!.elementAt(index).lon),
                    Map.moveToLatLonStatic(
                        new LatLng(widget._routePlaces!.elementAt(index).lon,
                            widget._routePlaces!.elementAt(index).lat),
                        zoom: 15)
                  }),
              itemBuilder: (context, i) => Transform.scale(
                scale: i == _index ? 1 : 0.9,
                child: InkWell(
                    onTap: () => {
                          Map.moveToLatLonStatic(
                              new LatLng(widget._routePlaces!.elementAt(i).lon,
                                  widget._routePlaces!.elementAt(i).lat),
                              zoom: 16)
                        },
                    child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 30),
                        child: SelectedPlace(
                          selectedPlace: widget._routePlaces!.elementAt(i),
                        ),
                        margin: EdgeInsets.only(),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(RADIUS),
                          color: Colors.white,
                        ))),
              ),
            )));
  }
}
