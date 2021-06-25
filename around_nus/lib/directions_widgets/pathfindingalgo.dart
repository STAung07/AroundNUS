import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';
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
  final int stopsAway;
  ConnectedBusStops({
    required this.routeName,
    required this.busStopName,
    required this.stopsAway,
  });
}

class PathFindingAlgo {
  final busService = NusNextBus();
  final Map<String, List<ConnectedBusStops>> adjacencyList;
  final Map<String, Position> busStopToPos;

  PathFindingAlgo({required this.adjacencyList, required this.busStopToPos});

  // function takes in start and end bus stop names
  // function returns shortest route between start and end bus stop
  String getBusPath(String startBusStopName, String endBusStopName) {
    // check if direct route
    // check connectedbusstops of startBusStopName
    List<ConnectedBusStops> currConnectedBusStops =
        adjacencyList[startBusStopName] as List<ConnectedBusStops>;
    String shortestPath = '';
    bool directRoute = false;
    int busStopsVisited = 36;
    for (var connectedBusStop in currConnectedBusStops) {
      PriorityQueue<ConnectedBusStops> minHeap = PriorityQueue(
        (ConnectedBusStops first, ConnectedBusStops second) {
          if (first.stopsAway < second.stopsAway) {
            return -1;
          }
          if (first.stopsAway > second.stopsAway) {
            return 1;
          }
          return 0;
        },
      );
      // if endbusstop found; check for shortest number of stops
      if (connectedBusStop.busStopName == endBusStopName) {
        directRoute = true;
        if (connectedBusStop.stopsAway < busStopsVisited) {
          shortestPath = connectedBusStop.routeName;
          busStopsVisited = connectedBusStop.stopsAway;
        }
      }
    }
    if (directRoute) {
      return shortestPath;
    }
    // if no direct route; use modified BFS;
    // maximum 2 hops
    return "";
  }
}
