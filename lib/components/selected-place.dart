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
    return Container(
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                _selectedPlace!.name,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        _selectedPlace!.name.toString().characters.length > 15
                            ? 15
                            : 22),
              ),
              Text(
                _selectedPlace!.address.getAddressOnUi(),
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Theme.of(context).accentColor),
              ),
            ]),
          ))
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RADIUS),
        color: Theme.of(context).backgroundColor,
      ),
    );
  }
}
