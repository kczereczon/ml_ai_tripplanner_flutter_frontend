import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class NewPlace extends StatefulWidget {
  const NewPlace({Key? key}) : super(key: key);

  @override
  _NewPlaceState createState() => _NewPlaceState();
}

class _NewPlaceState extends State<NewPlace> {
  String name = "";
  String street = "";
  String postCode = "";
  String city = "";
  String country = "";
  String state = "";

  final String? token = dotenv.env['MAPBOX_API_KEY'];
  final String style = 'mapbox://styles/mapbox/streets-v11';

  MapboxMapController? controller = null;

  set lat(double lat) {}

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
        body: PageView(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(MARGIN_HOME_LAYOUT),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                "Opowiedz o nowym miejscu",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Nazwa miejsca",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
              ),
              TextField(
                onChanged: (name) => this.name = name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Obelisk w lesie",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Opis",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
              ),
              TextField(
                onChanged: (name) => this.name = name,
                maxLines: 10,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText:
                      "Wielki mityczny kamień osadzony przez legendarnego ...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    onPressed: () => {
                          controller.nextPage(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.ease),
                        },
                    child: Text("Dalej",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(MAIN_COLOR_ALPHA),
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(MARGIN_HOME_LAYOUT),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                "Pokaż nam gdzie ono się znajduje ",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 5,
              ),
              FutureBuilder<Position>(
                  future: GeolocatorPlatform.instance.getCurrentPosition(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Position> snapshot) {
                    if (!snapshot.hasData) {
                      // while data is loading:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      // data loaded:
                      final position = snapshot.data;
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: MapboxMap(
                            styleString: style,
                            accessToken: token,
                            onMapCreated: (MapboxMapController controller) =>
                                this.controller = controller,
                            onMapClick: (Point point, LatLng latLng) async {
                              double lat = latLng.latitude;
                              double lon = latLng.longitude;
                              try {
                                Response response = await UsesApi.get(
                                    "/api/places/address/geocode",
                                    query: {
                                      "lat": lat.toStringAsFixed(6),
                                      "lon": lon.toStringAsFixed(6)
                                    });
                                Map<String, dynamic> data =
                                    jsonDecode(response.body);
                                List<dynamic> features =
                                    data["response"]["features"];
                                Map<String, dynamic> address = features[0];

                                setState(() {
                                  this.street = address['text'] +
                                      " " +
                                      address["relevance"].toString();
                                });

                                for (Map<String, dynamic> object
                                    in address["context"]) {
                                  print(object["id"].toString().split(".")[0]);
                                  setState(() {
                                    if (object["id"].toString().split(".")[0] ==
                                        "postcode") {
                                      this.postCode =
                                          object["text"].toString().trim();
                                    }
                                    if (object["id"].toString().split(".")[0] ==
                                        "place") {
                                      this.city =
                                          object["text"].toString().trim();
                                    }
                                    if (object["id"].toString().split(".")[0] ==
                                        "region") {
                                      this.state =
                                          object["text"].toString().trim();
                                    }
                                    if (object["id"].toString().split(".")[0] ==
                                        "country") {
                                      this.country =
                                          object["text"].toString().trim();
                                    }
                                  });
                                }
                              } catch (exception) {
                                print(exception.toString());
                              }

                              this.controller!.clearCircles();
                              this.controller!.addCircle(CircleOptions(
                                    geometry: latLng,
                                    circleRadius: 10,
                                    circleColor: "#70D799",
                                    circleStrokeColor: "#FFF3F3",
                                    circleStrokeWidth: 2,
                                  ));
                            },
                            initialCameraPosition: CameraPosition(
                                zoom: 15,
                                target: new LatLng(
                                    position!.latitude, position.longitude))),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      );
                    }
                  }),
              Text("Address",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("$street \n $postCode $city\n $state, $country"),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    onPressed: () => {
                          controller.nextPage(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.ease),
                        },
                    child: Text("Dalej",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(MAIN_COLOR_ALPHA),
                    )),
              ),
            ],
          ),
        ),
        Center(
          child: Text('Third Page'),
        )
      ],
    ));
  }
}
