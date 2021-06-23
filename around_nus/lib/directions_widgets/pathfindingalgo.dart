import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/pickuppointinfo_model.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busserviceinfo_model.dart';
import '../services/nusnextbus_service.dart';

// make adjacency list of connected bus stopws
// goes through all bus stops; for each busstop, call shuttle services to get
// shuttle services at each bus stop; get route names from list of Arrival Information
// for each route name, use pickuppoints info to get all busses connected to currBusStop
// adjacency list stores struct of Route Name and BusStop that can be reached by
// curr bus stop

class ConnectedBusStops {
  final String routeName;
  final String busStopName;
  ConnectedBusStops({
    required this.routeName,
    required this.busStopName,
  });
}

class PathFindingAlgo {
  final busService = NusNextBus();
  final Map<LatLng, List<ConnectedBusStops>> adjacencyList;

  PathFindingAlgo({required this.adjacencyList});
  // Map LatLng of each bus stop to its connected bus stops
  // function takes in start and end bus stop names
  // function returns shortest route between start and end bus stop
  void _getBusPath(String startBusStopName, String endBusStopName) {}
}
