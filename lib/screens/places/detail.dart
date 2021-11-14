import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/utils/constant.dart';
import 'package:laira/utils/uses-api.dart';
import 'package:http/http.dart' as http;

final storage = new FlutterSecureStorage();

class PlaceDetail extends StatefulWidget {
  const PlaceDetail({
    Key? key,
    this.place,
    this.tag,
  }) : super(key: key);

  final Place? place;
  final String? tag;

  @override
  _PlaceDetailState createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  void initState() {
    UsesApi.get('/api/places/' + widget.place!.id, context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: CarouselSlider(
                options: CarouselOptions(
                    autoPlay: false,
                    aspectRatio: 1,
                    enlargeCenterPage: false,
                    viewportFraction: 1),
                items: [
                  Container(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          // borderRadius:
                          //     BorderRadius.all(Radius.circular(RADIUS)),
                          image: DecorationImage(
                              image: NetworkImage(widget.place!.photoUrl),
                              fit: BoxFit.fill),
                        ),
                        child: GestureDetector(
                            //child: Image.network(i, fit: BoxFit.fill ),
                            onTap: () {
                          // Navigator.push<Widget>(
                          //   context,
                          //   MaterialPageRoute(
                          //     //builder: (context) => ImageScreen(i),
                          //   ),
                          // );
                        })),
                  )
                ],
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place!.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      widget.place!.address.getAddressOnUi(),
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 23),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        widget.place!.description,
                        style: TextStyle(
                            fontWeight: FontWeight.w200, fontSize: 18),
                      ),
                    ),
                  ])),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 30,
                    ),
                    Text(widget.place!.walkTime())
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.directions_bike,
                      size: 30,
                    ),
                    Text(widget.place!.bikeTime())
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 30,
                    ),
                    Text(widget.place!.carTime())
                  ],
                )
              ],
            ),
          ),
          CommentWrite(
            placeId: widget.place!.id,
          ),
          Comments()
        ]),
      ),
    ));
  }
}

class Comments extends StatelessWidget {
  const Comments({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 30, right: 16.0),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Comment(),
          Comment(),
          Comment(),
          Comment(),
          Comment(),
          Comment(),
        ],
      )),
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 10),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Kayaking_off_Na_Pali_coast.jpg/1200px-Kayaking_off_Na_Pali_coast.jpg"),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "John Kowalski",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    );
  }
}

class CommentWrite extends StatefulWidget {
  const CommentWrite({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  final String placeId;

  @override
  _CommentWriteState createState() => _CommentWriteState();
}

class _CommentWriteState extends State<CommentWrite> {
  Future<http.Response> _getUser({BuildContext? context}) async {
    return await UsesApi.get('/api/user/details', context: context);
  }

  String _description = "";

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.only(left: 16.0, top: 30, right: 16.0),
    //   child: Column(
    //     children: [
    //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    //         Padding(
    //           padding: const EdgeInsets.only(right: 5.0),
    //           child: CircleAvatar(
    //             radius: 28,
    //             backgroundImage: NetworkImage(
    //                 "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Kayaking_off_Na_Pali_coast.jpg/1200px-Kayaking_off_Na_Pali_coast.jpg"),
    //           ),
    //         ),
    //         Expanded(
    //             child: TextField(
    //           decoration: InputDecoration(
    //             filled: true,
    //             hintText: "Write comment",
    //             suffixIcon: Icon(Icons.send),
    //           ),
    //         )),
    //       ])
    //     ],
    //   ),
    // );
    return FutureBuilder(
      future: _getUser(context: context),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> map = jsonDecode(snapshot.data!.body);
          TextEditingController _controller = new TextEditingController();
          _controller.addListener(() => this._description = _controller.text);

          return Container(
            padding: const EdgeInsets.only(left: 16.0, top: 30, right: 16.0),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(map['test']
                                      ['profilePhoto'] !=
                                  null
                              ? map['test']['profilePhoto']
                              : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png"),
                        ),
                      ),
                      Expanded(
                          child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "Piszesz jako ${map['test']['name']}",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              UsesApi.post('/api/comments/places/', body: {
                                "place_id": widget.placeId,
                                "description": this._description,
                                "rating": 3
                              }).then((response) =>
                                  setState(() => _controller.clear()));
                            },
                          ),
                        ),
                      )),
                    ])
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }
}
