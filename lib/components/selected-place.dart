import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/screens/places/detail.dart';
import 'package:laira/utils/constant.dart';

class SelectedPlace extends StatelessWidget {
  const SelectedPlace(
      {Key? key, @required Place? selectedPlace, int offset = 0})
      : _selectedPlace = selectedPlace,
        _offset = offset,
        super(key: key);

  final Place? _selectedPlace;
  final int _offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 100 - _offset,
        child: Container(
          child: Row(
            children: [
              Hero(
                tag: _selectedPlace!.id,
                child: InkWell(
                  onTap: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PlaceDetail(
                            place: _selectedPlace, tag: _selectedPlace!.id)))
                  },
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(RADIUS),
                      child: Image.network(
                        _selectedPlace!.photoUrl,
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
                        _selectedPlace!.name,
                        style: TextStyle(
                            color: Color(0xFF70D799),
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      Text(
                        _selectedPlace!.address.getAddressOnUi(),
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 15),
                      ),
                    ]),
              ))
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RADIUS),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
