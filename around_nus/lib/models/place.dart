import 'package:around_nus/models/geometry.dart';

class Place {
  final Geometry? geometry;
  final String? name;
  final String? vicinity;
  final String? phoneNumber;
  // final String? openingHours;
  final String? address;
  final bool? isOpen;
  final List<dynamic>? openingHours;
  final List<String>? photoReference;

  Place(
      {this.geometry,
      this.name,
      this.vicinity,
      this.address,
      // this.openingHours,
      this.phoneNumber,
      this.isOpen,
      this.openingHours,
      this.photoReference});
  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    List<String> photoReferenceList = [];
    if (parsedJson["photos"] != null) {
      int photoLen = parsedJson["photos"].length;
      for (int i = 0; i < photoLen; i++) {
        photoReferenceList.add(parsedJson["photos"][i]["photo_reference"]);
      }
    }

    return Place(
        geometry: Geometry.fromJson(parsedJson["geometry"]),
        name: parsedJson["name"],
        vicinity: parsedJson["vicinity"],
        phoneNumber: parsedJson["formatted_phone_number"],
        // openingHours: parsedJson["opening_hours"],
        address: parsedJson["formatted_address"],
        // isOpen: OpeningHours.fromJson(parsedJson['opening_hours'])
        isOpen: parsedJson['opening_hours'] == null
            ? null
            : parsedJson['opening_hours']['open_now'],
        openingHours: parsedJson['opening_hours'] == null
            ? null
            : parsedJson['opening_hours']['weekday_text'],
        // photoReference: parsedJson["photos"] == null
        //     ? null
        //     : parsedJson["photos"][0]["photo_reference"]
        photoReference:
            parsedJson["photos"] == null ? null : photoReferenceList);
  }
}
