import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:around_nus/models/place.dart';
import 'package:around_nus/models/place_search.dart';
import 'package:around_nus/services/geolocator_service.dart';
import 'package:around_nus/services/places_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();

  //Variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  List<PlaceSearch>? searchFromResults;
  List<PlaceSearch>? searchToResults;
  // StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<Place> selectedLocation = BehaviorSubject();

  ApplicationBloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  searchFromPlaces(String searchTerm) async {
    searchFromResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  searchToPlaces(String searchTerm) async {
    searchToResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
