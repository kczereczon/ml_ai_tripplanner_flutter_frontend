import 'package:flutter/material.dart';

class PlaceDetail extends StatefulWidget {
  @override
  _PlaceDetailState createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffefefef),
      body: Column(
        children: [
          Image.network(
            "https://tropter.com/uploads/uploads/images/ce/b8/1df885b1d3b8bf8e6a764c7e023a54b722a7/letni_palac_lubomirskich_000_big.jpg?t=20200122105218",
            fit: BoxFit.cover,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Atraction",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                    ),
                    Text(
                      "ul. Lwowska 28, 37-610 Lipsko",
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 23),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        "Description description description",
                        style: TextStyle(
                            fontWeight: FontWeight.w200, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          size: 20,
                        ),
                      ],
                    ),
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
                                Text("1h 30m")
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.directions_bike,
                                  size: 30,
                                ),
                                Text("1h 30m")
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 30,
                                ),
                                Text("1h 30m")
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
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          fontSize: 13,),
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
