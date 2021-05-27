import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:laira/entities/address.dart';

class Place {
  final String photoUrl;
  final String name;
  final String id;
  final String description;
  final Address address;
  final double distance;
  final double rating;

  Place(this.photoUrl, this.name, this.id, this.description, this.address,
      this.distance, this.rating);

  String carTime() {
    return convertToTime(this.distance / 70000);
  }

  String walkTime() {
    return convertToTime(this.distance / 5000);
  }

  String bikeTime() {
    return convertToTime(this.distance / 20000);
  }

  String distanceUi() {
    return distanceFix(this.distance);
  }

  String convertToTime(double time) {
    int hrs = time.round();
    int min = (time.round() - hrs) * 60;

    String string = "";

    if (hrs > 1) {
      string += hrs.toString() + " h ";
    }
    if (min > 0) {
      string += min.toString() + " min";
    }
    if (hrs < 1 && min < 1) {
      string = ">1 min";
    }
    return string;
  }

  String distanceFix(double distance) {
    int km = (distance / 1000).round();
    int m = (distance - km).round() * 1000;

    String distanceString = "";

    if (km > 0) {
      distanceString += km.toString() + " km ";
    }

    if (m > 0) {
      distanceString += m.toString() + " m";
    } else if (km < 1 && m < 1) {
      distanceString = ">1 m";
    }

    return distanceString;
  }

  static Place parseFromJson(json) {
    return Place(
        json['image'],
        json['name'],
        json['_id'],
        json['description'] ?? "Testowy opis",
        Address(json['address']['street'], json['address']['number'],
            json['address']['postal_code'], json['address']['city']),
        double.parse(json['distance'].toString()),
        double.parse("4"));
  }

  Row getRating(double size) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < rating.round(); i++)
          Icon(
            Icons.star,
            size: size,
          )
      ],
    );
  }
}
