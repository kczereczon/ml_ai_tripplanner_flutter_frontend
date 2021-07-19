import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Planning extends StatefulWidget {
  @override
  _PlanningState createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  @override
  Widget build(BuildContext context) {
    MapboxMapController mapController;

    void _onMapCreated(MapboxMapController controller) {
      mapController = controller;
    }

    return new Container();
  }
}
