import 'package:around_nus/models/geometry.dart';

class Place {
  final Geometry? geometry;
  final String? name;
  final String? vicinity;
  final String? phoneNumber;
  final String? openingHours;
  final String? address;

  Place(
      {this.geometry,
      this.name,
      this.vicinity,
      this.address,
      this.openingHours,
      this.phoneNumber});
  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    return Place(
        geometry: Geometry.fromJson(parsedJson["geometry"]),
        name: parsedJson["formatted_address"],
        vicinity: parsedJson["vicinity"],
        phoneNumber: parsedJson["formatted_phone_number"],
        openingHours: parsedJson["opening_hours"],
        address: parsedJson["formatted_address"]);
  }
}
