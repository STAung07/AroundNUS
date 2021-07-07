import 'dart:async';
import 'package:around_nus/models/busstopsinfo_model.dart';
import 'package:around_nus/models/geometry.dart';
import 'package:around_nus/models/location.dart';
import 'package:around_nus/services/marker_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final markerService = MarkerService();

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
  List<BusStop>? searchBusStopsResults2;

  Place? selectedLocationStatic;
  String? placeType;

  List<Marker> markers = [];

  // StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<Place> selectedLocation = BehaviorSubject();
  StreamController<Place> selectedFromLocation = BehaviorSubject();
  StreamController<Place> selectedToLocation = BehaviorSubject();
  StreamController<LatLngBounds> bounds = BehaviorSubject();

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
    selectedLocationStatic = Place(
      geometry: Geometry(
        location: Location(
            lat: currentLocation!.latitude, lng: currentLocation!.longitude),
      ),
    );
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
    notifyListeners();
  }

  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = null;
    }

    if (placeType != null) {
      markers = [];

      var places = await placesService.getPlaces(
          selectedLocationStatic!.geometry!.location.lat,
          selectedLocationStatic!.geometry!.location.lng,
          placeType!);

      if (places.length > 0) {
        var newMarker = markerService.createMarkerFromPlace(places[0], false);
        markers.add(newMarker);
      }
      var locationMarker =
          markerService.createMarkerFromPlace(selectedLocationStatic!, false);
      markers.add(locationMarker);

      var _bounds = markerService.bounds(Set<Marker>.of(markers));
      bounds.add(_bounds);
    }

    notifyListeners();
  }

  // for the main map.dart page
  setSelectedLocation(String placeId) async {
    var sLocation = await placesService.getPlace(placeId);
    selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;
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

// directions page
  setFromSelectedLocation(String placeId) async {
    var fromLocation = await placesService.getPlace(placeId);
    selectedFromLocation.add(fromLocation);
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

  // directions page
  setToSelectedLocation(String placeId) async {
    var toLocation = await placesService.getPlace(placeId);
    selectedToLocation.add(toLocation);
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

  setNUSSelectedLocation(double lat, double lng, String _name) async {
    selectedLocationStatic = Place(
      name: _name,
      geometry: Geometry(
        location: Location(lat: lat, lng: lng),
      ),
    );
    // selectedLocation.add(selectedLocationStatic!);

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

  setNUSDirectionsSelectedLocation() async {
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

  setBusStopSelectedLocation(double lat, double lng, String _name) async {
    selectedLocationStatic = Place(
      name: _name,
      geometry: Geometry(
        location: Location(lat: lat, lng: lng),
      ),
    );
    // selectedLocation.add(selectedLocationStatic!);
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

  setBusStopDirectionsSelectedLocation() async {
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
