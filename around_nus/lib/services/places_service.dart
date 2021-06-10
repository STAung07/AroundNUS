import 'package:around_nus/models/place.dart';
import 'package:around_nus/models/place_search.dart';
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
    var url = "https://api.nusmods.com/v2/2020-2021/semesters/2/venues.json";
    var results = [];
    var response = await http.get(Uri.parse(url));
    var venues = convert.jsonDecode(response.body) as List;
    for (int i = 0; i < venues.length; i++) {
      if (venues[i].toLowerCase().contains(search.toLowerCase())) {
        print(venues[i]);
        results.add(venues[i]);
      }
    }
    return results;
  }

  Future<Place> getPlace(String place_id) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?key=$key&place_id=$place_id";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json["result"] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }
}
