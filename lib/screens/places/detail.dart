import 'package:flutter/material.dart';
import 'package:laira/entities/place.dart';

class PlaceDetail extends StatefulWidget {

  final Place place;

  final String tag;

  const PlaceDetail(
      {Key key, this.place, this.tag,
      })
      : super(key: key);
  @override
  _PlaceDetailState createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  @override
  Widget build(BuildContext context) {
    print(widget.tag);
    return Scaffold(
      backgroundColor: Color(0xfffefefef),
      body: Column(
        children: [
          Hero(
            tag: widget.tag,
            child: Image.network(
              widget.place.photoUrl,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                    ),
                    Text(
                      widget.place.address.getAddressOnUi(),
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 23),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        widget.place.description,
                        style: TextStyle(
                            fontWeight: FontWeight.w200, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    widget.place.getRating(20),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  size: 30,
                                ),
                                Text(widget.place.walkTime())
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.directions_bike,
                                  size: 30,
                                ),
                                Text(widget.place.bikeTime())
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 30,
                                ),
                                Text(widget.place.carTime())
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Kayaking_off_Na_Pali_coast.jpg/1200px-Kayaking_off_Na_Pali_coast.jpg"),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Write comment",
                              suffixIcon: Icon(Icons.send),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Kayaking_off_Na_Pali_coast.jpg/1200px-Kayaking_off_Na_Pali_coast.jpg"),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "John Kowalski",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          "02.03.2020",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text("Best place for holyday!"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
