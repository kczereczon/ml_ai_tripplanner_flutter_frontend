import 'package:flutter/material.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/selected-place.dart';
import 'package:laira/components/suggested-places.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/tabs/planning.dart';
import 'package:laira/utils/constant.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  bool _showSelectedComponent = false;
  bool _showSuggestedComponent = false;
  bool _showPlanRouteButton = false;
  bool _showCancelRouteButton = false;
  bool _showLocationButton = false;

  Widget? suggestedPlaces = Container();
  Widget? selectedPlace = Container();
  Place? _selectedPlace;
  Map? map;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        map = Map(
            onCirclePressed: (Circle circle) async => {
                  setState(() => {
                        _showSelectedComponent = true,
                        _showSuggestedComponent = true,
                        _selectedPlace = circle.data['place'],
                        selectedPlace = new SelectedPlace(
                          selectedPlace: _selectedPlace!,
                        ),
                        suggestedPlaces =
                            new SuggestedPlaces(onTap: _onSmallPlaceClicked),
                        map!.moveToLatLon(
                            new LatLng(circle.data['lon'], circle.data['lat']))
                      })
                },
            onCameraIdle: () {
              if (!_showPlanRouteButton && !_showLocationButton)
                setState(() => {
                      _showLocationButton = true,
                      _showPlanRouteButton = true,
                    });
            },
            onCameraMove: () {
              setState(() => {
                    _showSelectedComponent = false,
                    _showSuggestedComponent = false,
                    _showLocationButton = false,
                    _showPlanRouteButton = false,
                  });
            }),
        Visibility(child: suggestedPlaces!, visible: _showSuggestedComponent),
        Visibility(child: selectedPlace!, visible: _showSelectedComponent),
        Visibility(
          visible: _showPlanRouteButton,
          child: Positioned(
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
        ),
        Visibility(
          visible: _showLocationButton,
          child: Positioned(
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
                  onPressed: () => {map!.setCurrentPositon()}),
            ),
          ),
        )
      ],
    ));
  }

  void _onSmallPlaceClicked(place) {
    _selectedPlace = place;
    setState(() => {
          selectedPlace = new SelectedPlace(selectedPlace: place),
          suggestedPlaces = new SuggestedPlaces(onTap: _onSmallPlaceClicked)
        });
    map!.moveToLatLon(new LatLng(place.lon, place.lat));
  }

  Route<Object?> _dialogBuilder(BuildContext context, Object? arguments) {
    return DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Planning(mapController: Map.mapBoxController),
                ],
              ),
            ));
    ;
  }
}
