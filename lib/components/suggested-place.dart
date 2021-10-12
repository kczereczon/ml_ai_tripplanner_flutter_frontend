import 'package:flutter/material.dart';
import 'package:laira/entities/place.dart';
import 'package:laira/utils/constant.dart';

class SmallPlace extends StatelessWidget {
  const SmallPlace(
      {Key? key,
      @required Place? place,
      @required Function(Place)? onTap,
      @required bool? first})
      : _place = place,
        _onTap = onTap,
        _first = first,
        super(key: key);

  final Place? _place;
  final Function(Place)? _onTap;
  final bool? _first;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {_onTap!(_place!)},
      child: Padding(
        padding: EdgeInsets.only(
            right: MARGIN_HOME_LAYOUT,
            bottom: 50,
            left: _first! ? MARGIN_HOME_LAYOUT : 0),
        child: Container(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(RADIUS),
                child: Image.network(
                  _place!.photoUrl,
                  width: 100,
                  fit: BoxFit.cover,
                )),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RADIUS),
              color: LIGHT_COLOR_OBJECT,
            ),
            width:
                (MediaQuery.of(context).size.width - MARGIN_HOME_LAYOUT) / 3 -
                    MARGIN_HOME_LAYOUT),
      ),
    );
  }
}
