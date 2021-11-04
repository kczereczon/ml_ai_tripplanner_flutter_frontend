import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:image_picker/image_picker.dart';

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
  String description = "";

  final String? token = dotenv.env['MAPBOX_API_KEY'];
  final String style = 'mapbox://styles/mapbox/streets-v11';

  MapboxMapController? controller = null;

  final ImagePicker _picker = new ImagePicker();

  List<XFile> _imageFileList = [];

  String? _pickImageError;

  double lat = 0.0;
  double lon = 0.0;

  bool _nameInvalid = false;
  bool _descriptionInvalid = false;

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
                "Opowiedz o nowym miejscu 🤩",
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
                textCapitalization: TextCapitalization.words,
                onChanged: (name) => setState(() => this.name = name),
                inputFormatters: [],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _nameInvalid ? "Musisz uzupełnić nazwę!" : null,
                  hintText: "Tutaj powinna znaleźć się nazwa obiektu.",
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
                height: 10,
              ),
              Text("Opis",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
              ),
              TextField(
                textCapitalization: TextCapitalization.sentences,
                onChanged: (description) =>
                    setState(() => this.description = description),
                maxLines: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  errorText:
                      _descriptionInvalid ? "Musisz uzupełnić opis!" : null,
                  hintText:
                      "Opisz w kilku zdaniach co można znaleźć w nowymi miejscu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                    onPressed: () => {
                          setState(() => {
                                _nameInvalid = false,
                                _descriptionInvalid = false,
                              }),
                          if (name.isEmpty)
                            {
                              setState(() => {
                                    _nameInvalid = true,
                                  })
                            }
                          else if (description.isEmpty)
                            {
                              setState(() => {
                                    _descriptionInvalid = true,
                                  })
                            }
                          else
                            {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide'),
                              controller.nextPage(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.ease),
                            }
                        },
                    child: Text("Dalej 🥳",
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
                "Wskaż na mapie gdzie możemy znaleźć to miejsce 🧐",
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
                        height: 300,
                        child: MapboxMap(
                            styleString: style,
                            accessToken: token,
                            onMapCreated: (MapboxMapController controller) => {
                                  this.controller = controller,
                                  _getAddress(LatLng(
                                      position!.latitude, position.longitude))
                                },
                            onMapClick: (Point point, LatLng latlon) =>
                                {_getAddress(latlon)},
                            initialCameraPosition: CameraPosition(
                                zoom: 15,
                                target: new LatLng(
                                    position!.latitude, position.longitude))),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      );
                    }
                  }),
              Text("Adres",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Ulica",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(street,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Kod pocztow",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(postCode,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Miasto",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(city,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
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
                "Potrzebujemy zdjęć tego miejsca!",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () async {
                    try {
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.camera);
                      setState(() =>
                          {_imageFileList.clear(), _imageFileList.add(photo!)});
                    } catch (e) {
                      setState(() {
                        _pickImageError = e.toString();
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      SizedBox(width: 20),
                      Text("Aparat",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(LIGHTER_MAIN_COLOR_ALPHA),
                  )),
              TextButton(
                  onPressed: () async {
                    try {
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(() =>
                          {_imageFileList.clear(), _imageFileList.add(photo!)});
                    } catch (e) {
                      setState(() {
                        _pickImageError = e.toString();
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_album,
                        color: Colors.white,
                      ),
                      SizedBox(width: 20),
                      Text("Galeria",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(LIGHTER_MAIN_COLOR_ALPHA),
                  )),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Visibility(
                  visible: _imageFileList.length > 0,
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
              ),
              Expanded(child: _previewImages())
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
                "Podsumowanie 😍",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 5,
              ),
              Text("Nazwa miejsca",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(name,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Opis",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(description,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Ulica",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(street,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Kod pocztow",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(postCode,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Miasto",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(city,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Województwo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(state,
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
              SizedBox(
                height: 5,
              ),
              Text("Zdjęcie",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(child: _previewImages()),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Visibility(
                  visible: _imageFileList.length > 0,
                  child: TextButton(
                      onPressed: () async {
                        try {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.loading,
                              barrierDismissible: false,
                              text: "Dodaje nowe miejsce... 🥳");
                          Response? response = await UsesApi.multiPartPost(
                              '/api/places', File(_imageFileList[0].path),
                              body: {
                                "name": name,
                                "description": description,
                                "lat": lat.toString(),
                                "lon": lon.toString(),
                                "street": street,
                                "postal_code": postCode,
                                "city": city,
                              });
                          if (response!.statusCode == 200) {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          } else {
                            Navigator.pop(context);
                          }
                        } catch (e) {} finally {}
                      },
                      child: Text("Zapisz 💾",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300)),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(MAIN_COLOR_ALPHA),
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  void _getAddress(LatLng latLng) async {
    double lat = latLng.latitude;
    double lon = latLng.longitude;

    this.lat = lat;
    this.lon = lon;

    try {
      Response response = await UsesApi.get("/api/places/address/geocode",
          query: {
            "lat": lat.toStringAsFixed(6),
            "lon": lon.toStringAsFixed(6)
          });
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> features = data["response"]["features"];
      Map<String, dynamic> address = features[0];

      setState(() {
        this.street = address['text'] + " " + address["relevance"].toString();
      });

      for (Map<String, dynamic> object in address["context"]) {
        print(object["id"].toString().split(".")[0]);
        setState(() {
          if (object["id"].toString().split(".")[0] == "postcode") {
            this.postCode = object["text"].toString().trim();
          }
          if (object["id"].toString().split(".")[0] == "place") {
            this.city = object["text"].toString().trim();
          }
          if (object["id"].toString().split(".")[0] == "region") {
            this.state = object["text"].toString().trim();
          }
          if (object["id"].toString().split(".")[0] == "country") {
            this.country = object["text"].toString().trim();
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
  }

  Widget _previewImages() {
    if (_imageFileList.length > 0) {
      return Semantics(
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (context, index) {
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: Image.file(File(_imageFileList[index].path)),
              );
            },
            itemCount: _imageFileList.length,
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Tutaj pojawi się wybrane zdjęcie.',
        textAlign: TextAlign.center,
      );
    }
  }
}
