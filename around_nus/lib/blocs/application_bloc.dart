import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:around_nus/models/place.dart';
import 'package:around_nus/models/place_search.dart';
import 'package:around_nus/services/geolocator_service.dart';
import 'package:around_nus/services/places_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:around_nus/services/nusnextbus_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final busService = NusNextBus();

  //Variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  List<PlaceSearch>? searchFromResults;
  List<PlaceSearch>? searchToResults;
  List? searchNUSResults;
  List? searchBusStopsResults;
  // StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<Place> selectedLocation = BehaviorSubject();

  ApplicationBloc() {
    setCurrentLocation();
  }
  searchNUSPlaces(String searchTerm) async {
    searchNUSResults = await placesService.getNUSAutoComplete(searchTerm);
    notifyListeners();
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

  searchBusStops(String searchTerm) async {
    //searchBusStopsResults = await fetchBusStopInfo(searchTerm);
    searchBusStopsResults = await busService.autoCompleteBusStops(searchTerm);
    print(searchBusStopsResults);
    print("here");
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = null;
    searchFromResults = null;
    searchToResults = null;
    searchNUSResults = null;
    notifyListeners();
  }

  setNUSSelectedLocation() async {
    searchNUSResults = null;
    searchResults = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
