import 'package:around_nus/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerService {
  LatLngBounds bounds(Set<Marker> markers) {
    if (markers == null || markers.isEmpty)
      return LatLngBounds(northeast: LatLng(0, 0), southwest: LatLng(0, 0));
    return createBounds(markers.map((m) => m.position).toList());
  }

  LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  // Marker createMarkerFromLatLng(
  //     String name, double lat, double lng, bool center) {
  //   var markerId = name;
  //   if (center) markerId = 'center';

  //   return Marker(
  //       markerId: MarkerId(markerId),
  //       draggable: false,
  //       visible: (center) ? false : true,
  //       infoWindow: InfoWindow(title: name),
  //       position: LatLng(lat, lng));
  // }

  Marker createMarkerFromPlace(Place place, bool center, bool searched) {
    var markerId = place.name;
    var markerColour = BitmapDescriptor.hueRed;
    if (center) markerId = 'center';
    if (!searched) markerColour = BitmapDescriptor.hueGreen;
    return Marker(
        markerId: MarkerId(markerId!),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerColour),
        draggable: false,
        visible: true,
        //infoWindow: InfoWindow(title: place.name, snippet: place.vicinity),
        position:
            LatLng(place.geometry!.location.lat, place.geometry!.location.lng));
  }
}
