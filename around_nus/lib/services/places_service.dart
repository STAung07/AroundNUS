import 'package:around_nus/models/location.dart';
import 'package:around_nus/models/place.dart';
import 'package:around_nus/models/place_info.dart';
import 'package:around_nus/models/place_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  final key = "AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M";
  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    // var url =
    //     "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key";
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?strictbounds=&input=$search&location=1.2966,103.7764&key=$key&radius=900";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<List> getNUSAutoComplete(String search) async {
    var url = "https://api.nusmods.com/v2/2020-2021/semesters/3/venues.json";
    var results = [];
    var response = await http.get(Uri.parse(url));
    var venues = convert.jsonDecode(response.body) as List;
    for (int i = 0; i < venues.length; i++) {
      if (venues[i].toLowerCase().startsWith(search.toLowerCase())) {
        results.add(venues[i]);
        // print(venues[i]["description"]);
      }
    }
    return results;
  }

  // Future<PlaceInfo> getPlaceInfo(String place_id) async {
  //   var url =
  //       "https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJV3P-dqsb2jERcA1t9E1fPps&fields=name,formatted_phone_number,opening_hours,formatted_address&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M";
  //   var response = await http.get(Uri.parse(url));
  //   var json = convert.jsonDecode(response.body);
  //   var jsonResult = json["result"] as Map<String, dynamic>;
  //   return PlaceInfo.fromJson(jsonResult);
  // }

  Future<Place> getPlace(String place_id) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&fields=name,formatted_phone_number,formatted_address,geometry,vicinity&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json["result"] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(
      double lat, double lng, String placeType) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?type=$placeType&location=$lat,$lng&rankby=distance&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json["results"] as List;
    return jsonResult.map((place) => Place.fromJson(place)).toList();
  }
}
