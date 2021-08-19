import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

final storage = new FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  MapboxMapController _mapboxMapController;
  Map<String, Circle> _circles = {};

  bool _selectedPlaceVisable = false;
  bool _wasCameraIdle = true;

  Place _selectedPlace = null;
  Widget _selectedPlaceUi = null;
  List<Widget> _additionalStackWidgets = [];

  List<Place> _placeList;

  LatLng _initialPosition = LatLng(
    50.3485116,
    23.333414,
  );

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

  void _onSmallPlaceClicked(place) {
    _additionalStackWidgets.clear();
    _wasCameraIdle = false;
    _selectedPlace = place;
    setState(() => {
          _additionalStackWidgets.add(
            new SelectedPlaceQuickInfo(selectedPlace: place),
          ),
          _additionalStackWidgets
              .add(new SuggestedPlaces(onTap: _onSmallPlaceClicked))
        });
    _getCameraPosition(_mapboxMapController, new LatLng(place.lon, place.lat))
        .then((animation) => _mapboxMapController.animateCamera(animation));
  }

  void _onMapCreated(MapboxMapController controller) async {
    _setCurrentPositon(controller);
    controller.onCircleTapped.add((Circle circle) async => {
          setState(() => {
                _additionalStackWidgets.clear(),
                _wasCameraIdle = false,
                _selectedPlace = circle.data['place'],
                _additionalStackWidgets.add(
                    new SelectedPlaceQuickInfo(selectedPlace: _selectedPlace)),
                _additionalStackWidgets.add(
                  new SuggestedPlaces(onTap: _onSmallPlaceClicked),
                )
              }),
          controller.animateCamera(await _getCameraPosition(
              controller, new LatLng(circle.data['lon'], circle.data['lat'])))
        });

    controller.addListener(() {
      if (this._additionalStackWidgets.length > 0 &&
          controller.isCameraMoving &&
          _wasCameraIdle) {
        setState(() => {_additionalStackWidgets.clear()});
      }
    });

    List<Place> places = await _getPlaces();
    _placeList = places;
    print(_placeList);
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
            "place": place
          }).then((circle) => _circles.addAll({place.id: circle}));

      // controller.addCircle(options)(SymbolOptions(
      //     iconImage: "pin", geometry: new LatLng(place.lat, place.lon)));
      _mapboxMapController = controller;
    }
  }

  Future<CameraUpdate> _getCameraPosition(
      MapboxMapController controller, LatLng target) async {
    CameraPosition position = new CameraPosition(target: target, zoom: 11);

    return CameraUpdate.newCameraPosition(position);
  }

  void _setCurrentPositon(MapboxMapController controller) async {
    LatLng newPositon = await _getUserLocation();
    controller.animateCamera(await _getCameraPosition(controller, newPositon));
    controller.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
  }

  Future<List<Place>> _getPlaces() async {
    String token = await storage.read(key: 'jwt');
    if (token == null) {
      await Navigator.pushReplacementNamed(context, "/login");
    }
    final List<Place> places = [];
    final response = await http.get(
        Uri.http(dotenv.env['API_HOST_IP'], '/api/places/all'),
        headers: {'auth-token': token});
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

  Widget build(BuildContext context) {
    final String style = 'mapbox://styles/mapbox/streets-v11';

    return new Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.location_pin),
            onPressed: () => {_setCurrentPositon(_mapboxMapController)}),
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            MapboxMap(
              styleString: style,
              accessToken: token,
              myLocationEnabled: true,
              onCameraIdle: () => _wasCameraIdle = true,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 18.0,
              ),
              onMapCreated: _onMapCreated,
            ),
            ..._additionalStackWidgets
          ],
        ));
  }
}

class SuggestedPlaces extends StatelessWidget {
  const SuggestedPlaces({
    Key key,
    @required Function(Place) onTap,
  })  : _onTap = onTap,
        super(key: key);

  final Function(Place) _onTap;

  Future<List<Place>> _getSuggestedPlaces() async {
    String token = await storage.read(key: 'jwt');
    final List<Place> places = [];
    final response = await http.get(
        Uri.http(dotenv.env['API_HOST_IP'], '/api/places/suggested'),
        headers: {'auth-token': token});
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

  @override
  Widget build(BuildContext context) {
    // SmallPlace(place: , onTap: _onTap),
    return Positioned(
      top: 208,
      child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width - 50,
          child: FutureBuilder(
              future: _getSuggestedPlaces(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
                if (snapshot.hasData) {
                  List<SmallPlace> places = [];
                  for (Place place in snapshot.data) {
                    places.add(new SmallPlace(place: place, onTap: _onTap));
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

class SmallPlace extends StatelessWidget {
  const SmallPlace(
      {Key key, @required Place place, @required Function(Place) onTap})
      : _place = place,
        _onTap = onTap,
        super(key: key);

  final Place _place;
  final Function(Place) _onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {_onTap(_place)},
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Container(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _place.photoUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                )),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: 70,
            height: 70),
      ),
    );
  }
}

class SelectedPlaceQuickInfo extends StatelessWidget {
  const SelectedPlaceQuickInfo({
    Key key,
    @required Place selectedPlace,
  })  : _selectedPlace = selectedPlace,
        super(key: key);

  final Place _selectedPlace;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      child: Container(
        width: MediaQuery.of(context).size.width - 50,
        height: 150,
        child: Row(
          children: [
            Hero(
              tag: _selectedPlace.id,
              child: InkWell(
                onTap: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PlaceDetail(
                          place: _selectedPlace, tag: _selectedPlace.id)))
                },
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      _selectedPlace.photoUrl,
                      height: 140,
                      width: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding:
                  const EdgeInsets.only(left: 5, top: 8, right: 8, bottom: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlace.name,
                      style: TextStyle(
                          color: Color(0xFF70D799),
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                    Text(
                      _selectedPlace.address.getAddressOnUi(),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                    ),
                  ]),
            ))
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
      ),
    );
  }
}
