import 'dart:async';
import 'package:around_nus/models/busstopsinfo_model.dart';
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
  List<BusStop>? searchFromBusStopsResults;
  List<BusStop>? searchToBusStopsResults;
  List<BusStop>? searchBusStopsResults;
  List? searchNUSResults;
  List? searchNUSFromResults;
  List? searchNUSToResults;
  List? searchBusStopsResults2;

  // StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<Place> selectedLocation = BehaviorSubject();

  ApplicationBloc() {
    setCurrentLocation();
  }
  searchNUSPlaces(String searchTerm) async {
    searchNUSResults = await placesService.getNUSAutoComplete(searchTerm);
    notifyListeners();
  }

  searchNUSFromPlaces(String searchTerm) async {
    searchNUSFromResults = await placesService.getNUSAutoComplete(searchTerm);
    notifyListeners();
  }

  searchNUSToPlaces(String searchTerm) async {
    searchNUSToResults = await placesService.getNUSAutoComplete(searchTerm);
    notifyListeners();
  }

  searchFromBusStops(String searchTerm) async {
    //searchBusStopsResults = await fetchBusStopInfo(searchTerm);
    searchFromBusStopsResults = await busService.getBusStops(searchTerm);
    print("search bus stop: ");
    print(searchBusStopsResults);
    notifyListeners();
  }

  searchToBusStops(String searchTerm) async {
    //searchBusStopsResults = await fetchBusStopInfo(searchTerm);
    searchToBusStopsResults = await busService.getBusStops(searchTerm);
    notifyListeners();
  }

  searchBusStops(String searchTerm) async {
    //searchBusStopsResults = await fetchBusStopInfo(searchTerm);
    searchBusStopsResults = await busService.getBusStops(searchTerm);
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

  searchBusStops2(String searchTerm) async {
    //searchBusStopsResults = await fetchBusStopInfo(searchTerm);
    searchBusStopsResults2 = await busService.autoCompleteBusStops(searchTerm);
    // print(searchBusStopsResults);
    // print("here");
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = null;
    searchFromResults = null;
    searchToResults = null;
    searchNUSResults = null;
    searchNUSFromResults = null;
    searchNUSToResults = null;
    searchFromBusStopsResults = null;
    searchToBusStopsResults = null;
    searchBusStopsResults = null;
    notifyListeners();
  }

  setNUSSelectedLocation() async {
    searchResults = null;
    searchFromResults = null;
    searchToResults = null;
    searchNUSResults = null;
    searchNUSFromResults = null;
    searchNUSToResults = null;
    searchFromBusStopsResults = null;
    searchToBusStopsResults = null;
    searchBusStopsResults = null;

    notifyListeners();
  }

  setBusStopSelectedLocation() async {
    searchResults = null;
    searchFromResults = null;
    searchToResults = null;
    searchNUSResults = null;
    searchNUSFromResults = null;
    searchNUSToResults = null;
    searchFromBusStopsResults = null;
    searchToBusStopsResults = null;
    searchBusStopsResults = null;

    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
