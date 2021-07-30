import 'package:around_nus/models/geometry.dart';
import 'package:around_nus/models/opening_hours.dart';

class Place {
  final Geometry? geometry;
  final String? name;
  final String? vicinity;
  final String? phoneNumber;
  // final String? openingHours;
  final String? address;
  final OpeningHours? isOpen;

  Place(
      {this.geometry,
      this.name,
      this.vicinity,
      this.address,
      // this.openingHours,
      this.phoneNumber,
      this.isOpen});
  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    return Place(
        geometry: Geometry.fromJson(parsedJson["geometry"]),
        name: parsedJson["name"],
        vicinity: parsedJson["vicinity"],
        phoneNumber: parsedJson["formatted_phone_number"],
        // openingHours: parsedJson["opening_hours"],
        address: parsedJson["formatted_address"],
        isOpen: OpeningHours.fromJson(parsedJson['opening_hours']));
  }
}
