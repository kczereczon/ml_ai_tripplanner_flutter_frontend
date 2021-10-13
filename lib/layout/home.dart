import 'package:flutter/material.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/route-plan-places.dart';
import 'package:laira/components/selected-place.dart';
import 'package:laira/components/suggested-places.dart';
import 'package:laira/composables/Places.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/tabs/planning.dart';
import 'package:laira/utils/constant.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:progress_dialog/progress_dialog.dart';

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
                  Map.putHighlightCircle(
                      circle.data['lat'], circle.data['lon']),
                  selectedPlace = new SelectedPlace(
                    selectedPlace: _selectedPlace!,
                    offset: 0,
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
        ),
        Visibility(child: suggestedPlaces!, visible: _showSuggestedComponent),
        Visibility(child: selectedPlace!, visible: _showSelectedComponent),
        Visibility(child: routePlanPlaces!, visible: _shorRoutePlannedPlaces),
        Visibility(
            visible: _showPlanRouteButton,
            child: RoutePlanButton(
                context: context,
                onSuccess: () {
                  setState(() => {
                        _showSuggestedComponent = false,
                        _showSelectedComponent = false,
                      });
                })),
        Visibility(
          visible: _showCancelRouteButton,
          child: RouteCancelButton(
              context: context,
              onClick: () => {
                    setState(() {
                      _showPlanRouteButton = true;
                      _showCancelRouteButton = false;
                      _showSuggestedComponent = false;
                      _shorRoutePlannedPlaces = false;
                      _isRoutePlanned = false;
                      Map.mapBoxController!.clearCircles();
                      Map.mapBoxController!
                          .removeSymbols(Map.mapBoxController!.symbols);
                      Map.mapBoxController!.clearLines();
                      Map.mapBoxController!.symbols.clear();

                      Map.mapBoxController!.updateMyLocationTrackingMode(
                          MyLocationTrackingMode.Tracking);

                      ProgressDialog pd = new ProgressDialog(context);
                      pd.show();
                      Placess.getPlace().then((places) async => {
                            for (Place place in places)
                              {
                                Map.mapBoxController?.addCircle(
                                    CircleOptions(
                                        circleRadius: 10,
                                        circleColor: "#70D799",
                                        circleStrokeColor: "#FFF3F3",
                                        circleStrokeWidth: 2,
                                        geometry:
                                            new LatLng(place.lon, place.lat)),
                                    {
                                      "lat": place.lat,
                                      "lon": place.lon,
                                      "address": place.address.getAddressOnUi(),
                                      "name": place.name,
                                      "image": place.photoUrl,
                                      "place": place,
                                      "showInfo": true,
                                      "marker": false
                                    })
                              },
                            pd.hide(),
                          });
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
    Map.putHighlightCircle(place.lat, place.lon);
    setState(() => {
          selectedPlace = new SelectedPlace(selectedPlace: place),
          suggestedPlaces = new SuggestedPlaces(onTap: _onSmallPlaceClicked)
        });
    map!.moveToLatLon(new LatLng(place.lon, place.lat), zoom: 15);
  }
}

class RoutePlanButton extends StatelessWidget {
  RoutePlanButton(
      {Key? key,
      @required BuildContext? context,
      @required Function? onSuccess})
      : _context = context,
        _onSuccess = onSuccess,
        super(key: key);

  final BuildContext? _context;
  final Function? _onSuccess;

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
              String result = await showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(RADIUS))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Planning(
                              mapController: Map.mapBoxController,
                              onMapPlanned:
                                  (List<Place> places, List<LatLng> lines) {
                                _HomeLayoutState._plannedRoute.clear();
                                Map.mapBoxController!.clearLines();
                                Map.mapBoxController!.clearCircles();
                                Map.mapBoxController!.removeSymbols(
                                    Map.mapBoxController!.symbols);
                                Map.mapBoxController!.symbols.clear();
                                Map.mapBoxController!.addLine(LineOptions(
                                    lineWidth: 10,
                                    lineColor: "#9fD799",
                                    lineOpacity: 0.8,
                                    geometry: lines));
                                Map.mapBoxController!
                                    .updateMyLocationTrackingMode(
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
                                          geometry:
                                              new LatLng(place.lon, place.lat)),
                                      {
                                        "lat": place.lat,
                                        "lon": place.lon,
                                        "address":
                                            place.address.getAddressOnUi(),
                                        "name": place.name,
                                        "image": place.photoUrl,
                                        "place": place,
                                        "distance": place.distance,
                                        "plan": true,
                                        "marker": false
                                      });
                                  Map.mapBoxController!.addSymbol(SymbolOptions(
                                      textField: (count++).toString(),
                                      textSize: 15,
                                      textColor: "#FFF3F3",
                                      geometry:
                                          new LatLng(place.lon, place.lat)));
                                }
                                _HomeLayoutState.routePlanPlaces =
                                    new RoutePlanPlaces(
                                  routePlaces: _HomeLayoutState._plannedRoute,
                                );
                                _HomeLayoutState._showPlanRouteButton = false;
                                _HomeLayoutState._shorRoutePlannedPlaces = true;
                                _HomeLayoutState._showSuggestedComponent =
                                    false;
                                _HomeLayoutState._showSelectedComponent = false;
                                _HomeLayoutState._showCancelRouteButton = true;
                                _HomeLayoutState._isRoutePlanned = true;
                              },
                            ),
                          ],
                        ),
                      ));
              _onSuccess!();
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
