import 'package:flutter/material.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/route-plan-places.dart';
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
  static bool _showSelectedComponent = false;
  static bool _showSuggestedComponent = false;
  static bool _showPlanRouteButton = false;
  static bool _showCancelRouteButton = false;
  static bool _showLocationButton = false;
  static bool _shorRoutePlannedPlaces = false;
  static bool _isRoutePlanned = false;

  Widget? suggestedPlaces = Container();
  Widget? selectedPlace = Container();
  static Widget? routePlanPlaces = Container();
  Place? _selectedPlace;
  Map? map;
  static List<Place> _plannedRoute = [];

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
                      if (_isRoutePlanned)
                        {
                          _shorRoutePlannedPlaces = true,
                          _showSuggestedComponent = true,
                          _showCancelRouteButton = true,
                        }
                      else
                        {
                          if (_selectedPlace != null)
                            {_shorRoutePlannedPlaces = true},
                          _showPlanRouteButton = true,
                        }
                    });
            },
            onCameraMove: () {
              setState(() => {
                    _shorRoutePlannedPlaces = false,
                    _showSelectedComponent = false,
                    _showSuggestedComponent = false,
                    _showLocationButton = false,
                    _showPlanRouteButton = false,
                    _showCancelRouteButton = false,
                  });
            }),
        Visibility(child: suggestedPlaces!, visible: _showSuggestedComponent),
        Visibility(child: selectedPlace!, visible: _showSelectedComponent),
        Visibility(child: routePlanPlaces!, visible: _shorRoutePlannedPlaces),
        Visibility(
            visible: _showPlanRouteButton,
            child: RoutePlanButton(context: context)),
        Visibility(
          visible: _showCancelRouteButton,
          child: RouteCancelButton(
              context: context,
              onClick: () => {
                    setState(() => {
                          _showPlanRouteButton = true,
                          _showCancelRouteButton = false,
                          _showSuggestedComponent = false,
                          _shorRoutePlannedPlaces = false,
                          _isRoutePlanned = false,
                          Map.mapBoxController!.clearCircles(),
                          Map.mapBoxController!.clearSymbols(),
                          Map.mapBoxController!.clearLines()
                        })
                  }),
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
}

class RoutePlanButton extends StatelessWidget {
  RoutePlanButton({Key? key, @required BuildContext? context})
      : _context = context,
        super(key: key);

  final BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 50,
        left: 15,
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width - 90,
          decoration: BoxDecoration(),
          child: TextButton(
            onPressed: () async {
              Navigator.of(_context!).restorablePush(_dialogBuilder);
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
        ));
  }

  static Route<Object?> _dialogBuilder(
      BuildContext context, Object? arguments) {
    return DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(RADIUS))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Planning(
                    mapController: Map.mapBoxController,
                    onMapPlanned: (List<Place> places, List<LatLng> lines) {
                      Map.mapBoxController!.clearLines();
                      Map.mapBoxController!.clearCircles();
                      Map.mapBoxController!.clearSymbols();
                      Map.mapBoxController!.addLine(LineOptions(
                          lineWidth: 10,
                          lineColor: "#9fD799",
                          lineOpacity: 0.8,
                          geometry: lines));
                      Map.mapBoxController!.updateMyLocationTrackingMode(
                          MyLocationTrackingMode.TrackingCompass);
                      Map.mapBoxController!
                          .animateCamera(CameraUpdate.zoomTo(14));
                      int count = 1;
                      for (Place place in places) {
                        _HomeLayoutState._plannedRoute.add(place);
                        Map.mapBoxController!.addCircle(
                            CircleOptions(
                                circleRadius: 10,
                                circleColor: DARKER_MAIN_COLOR_STRING,
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
                              "distance": place.distance,
                              "plan": true
                            });
                        Map.mapBoxController!.addSymbol(SymbolOptions(
                            textField: (count++).toString(),
                            textSize: 15,
                            textColor: "#FFF3F3",
                            geometry: new LatLng(place.lon, place.lat)));
                      }
                      _HomeLayoutState.routePlanPlaces = new RoutePlanPlaces(
                        routePlaces: _HomeLayoutState._plannedRoute,
                      );
                      _HomeLayoutState._showPlanRouteButton = false;
                      _HomeLayoutState._shorRoutePlannedPlaces = true;
                      _HomeLayoutState._showSuggestedComponent = true;
                      _HomeLayoutState._showCancelRouteButton = true;
                      _HomeLayoutState._isRoutePlanned = true;
                    },
                  ),
                ],
              ),
            ));
    ;
  }
}

class RouteCancelButton extends StatelessWidget {
  RouteCancelButton(
      {Key? key, @required BuildContext? context, @required Function? onClick})
      : _context = context,
        _onClick = onClick,
        super(key: key);

  final BuildContext? _context;
  final Function? _onClick;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 50,
        left: 15,
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width - 90,
          decoration: BoxDecoration(),
          child: TextButton(
            onPressed: () async {
              _onClick!();
            },
            child: Text("Anuluj trasę",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300)),
            style: TextButton.styleFrom(
                backgroundColor: Color(0xFFc44240),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RADIUS))),
          ),
        ));
  }
}
