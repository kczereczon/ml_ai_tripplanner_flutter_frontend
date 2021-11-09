import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laira/components/map.dart';
import 'package:laira/components/route-plan-places.dart';
import 'package:laira/components/selected-place.dart';
import 'package:laira/components/suggested-places.dart';
import 'package:laira/composables/Places.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/tabs/planning.dart';
import 'package:laira/utils/constant.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:laira/main.dart';

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
  static bool _showNewPlaceButton = true;

  Widget? suggestedPlaces = Container();
  Widget? selectedPlace = Container();
  static Widget? routePlanPlaces = Container();
  Place? _selectedPlace;
  Map? map;
  static List<Place> _plannedRoute = [];

  Loading? _loading = Loading();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        FutureBuilder<Position>(
            future: GeolocatorPlatform.instance.getCurrentPosition(),
            builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
              if (!snapshot.hasData) {
                // while data is loading:
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final position = snapshot.data;
                return map = Map(
                    initialCameraPosition: CameraPosition(
                        zoom: 15,
                        target:
                            new LatLng(position!.latitude, position.longitude)),
                    onCameraMove: () {},
                    onCirclePressed: (Circle circle) async => {
                          setState(() => {
                                _showSelectedComponent = true,
                                _showSuggestedComponent = true,
                                _selectedPlace = circle.data!['place'],
                                Map.putHighlightCircle(
                                    circle.data!['lat'], circle.data!['lon']),
                                selectedPlace = new Positioned(
                                  bottom: 120,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 30,
                                    child: SelectedPlace(
                                      selectedPlace: _selectedPlace!,
                                    ),
                                  ),
                                ),
                                suggestedPlaces = new SuggestedPlaces(
                                    onTap: _onSmallPlaceClicked),
                                map!.moveToLatLon(new LatLng(
                                    circle.data!['lon'], circle.data!['lat']))
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
                    });
              }
            }),
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
                        _showNewPlaceButton = false,
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
                      _showNewPlaceButton = true;
                      Map.mapBoxController!.clearCircles();
                      Map.mapBoxController!
                          .removeSymbols(Map.mapBoxController!.symbols);
                      Map.mapBoxController!.clearLines();
                      Map.mapBoxController!.symbols.clear();

                      Map.mapBoxController!.updateMyLocationTrackingMode(
                          MyLocationTrackingMode.Tracking);
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.loading,
                          text: "Pobieram punkty... 👀",
                          barrierDismissible: false);

                      Placess.getPlace().then((places) => {
                            for (Place place in places)
                              {
                                Map.mapBoxController?.addCircle(
                                    CircleOptions(
                                        circleRadius: 10,
                                        circleColor: Theme.of(context)
                                            .primaryColor
                                            .toHex(),
                                        circleStrokeColor: Theme.of(context)
                                            .accentColor
                                            .toHex(),
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
                          });

                      Navigator.pop(context);
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
                  child: Icon(Icons.location_pin,
                      color: Theme.of(context).primaryColor),
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RADIUS)),
                  onPressed: () => {map!.setCurrentPositon()}),
            ),
          ),
        ),
        Visibility(
          visible: _showNewPlaceButton,
          child: Positioned(
            top: 50,
            right: 15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(),
              child: FloatingActionButton(
                  child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RADIUS)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/new-place').then((value) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.loading,
                          text: "Pobieram punkty... 👀",
                          barrierDismissible: false);
                      Placess.getPlace().then((places) => {
                            for (Place place in places)
                              {
                                Map.mapBoxController?.addCircle(
                                    CircleOptions(
                                        circleRadius: 10,
                                        circleColor: Theme.of(context)
                                            .primaryColor
                                            .toHex(),
                                        circleStrokeColor: Theme.of(context)
                                            .accentColor
                                            .toHex(),
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
                          });
                      Navigator.of(context, rootNavigator: true).pop();
                    });
                  }),
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
          selectedPlace = new Positioned(
              bottom: 120,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: SelectedPlace(
                  selectedPlace: place!,
                ),
              )),
          suggestedPlaces = new SuggestedPlaces(onTap: _onSmallPlaceClicked)
        });
    map!.moveToLatLon(new LatLng(place.lon, place.lat), zoom: 15);
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
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
                    color: Theme.of(context).accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300)),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
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
                    color: Theme.of(context).accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300)),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RADIUS))),
          ),
        ));
  }
}
