import 'dart:ffi';
import 'dart:math';

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

  // function checks if two bus stops are connected directly
  // bool isDirectlyConnected(String startBusStopName, endBusStopName) {
  //   List<ConnectedBusStops> currConnectedBusStops =
  //       adjacencyList[startBusStopName] as List<ConnectedBusStops>;

  //   // scan through all the possible direction connections in startBusStopName and
  //   // check if endBusStopName is in it to see if it is reachable
  //   for (var connectedBusStop in currConnectedBusStops) {
  //     if (connectedBusStop.busStopName == endBusStopName) return true;
  //   }
  //   return false;
  // }

  // find the distance between two coordinates in metres

  late BusStop startingBusStop;
  late BusStop endingBusStop;
  int leastStops = 35;

  double _coordinatedistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * 1000 * asin(sqrt(a)));
  }

  // function takes in starting and ending coordinates
  // finds nearest bus stop with shortest direct path
  // function returns shortestPath
  String getBusPath(
      /*String startBusStopName, String endBusStopName,*/
      Position startingPoint,
      Position endingPoint,
      List<BusStop> nusBusStops) {
    // get nearby bus stops from starting and ending point and see if they are connected
    // and also find the shortest path
    List<BusStop> nearbyStartingBusStops = [];
    List<BusStop> nearbyEndingBusStops = [];
    String shortestPath = '';

    // get list of nearby bus stops to starting position
    for (BusStop busStop in nusBusStops) {
      double distance = _coordinatedistance(startingPoint.latitude,
          startingPoint.longitude, busStop.latitude, busStop.longitude);
      //within distance of 100 m
      if (distance < 200) {
        nearbyStartingBusStops.add(busStop);
        print(busStop.name);
        print("is nearby the start");
      }
    }

    // get list of nearby ending bus stops
    for (BusStop busStop in nusBusStops) {
      double distance = _coordinatedistance(endingPoint.latitude,
          endingPoint.longitude, busStop.latitude, busStop.longitude);
      if (distance < 200) {
        nearbyEndingBusStops.add(busStop);
        print(busStop.name);
        print("is nearby the end");
      }
    }

    // check if the nearby starting bus stops and the end bus stop are directly connected
    // if they are find the ones with least stops
    for (BusStop start in nearbyStartingBusStops) {
      print("start:");
      print(start.name);
      for (BusStop end in nearbyEndingBusStops) {
        print("end:");
        print(end.name);
        List<ConnectedBusStops> currConnectedBusStops =
            adjacencyList[start.name] as List<ConnectedBusStops>;

        // scan through all the possible direction connections in startBusStopName and
        // check if endBusStopName is in it to see if it is reachable
        for (var connectedBusStop in currConnectedBusStops) {
          if (connectedBusStop.busStopName == end.name) {
            // is connected then take note of how many stops and route
            if (connectedBusStop.stopsAway < leastStops) {
              shortestPath = connectedBusStop.routeName;
              leastStops = connectedBusStop.stopsAway;
              startingBusStop = start;
              endingBusStop = end;
            }
          }
        }
      }
    }
    print("the shortest path is ");
    print(shortestPath +
        "," +
        startingBusStop.name +
        "," +
        endingBusStop.name +
        "," +
        leastStops.toString());
    return shortestPath;
    // "," +
    // startingBusStopName +
    // "," +
    // endingBusStopName +
    // "," +
    // leastStops.toString();
  }

  BusStop getStartingBusStop() {
    return startingBusStop;
  }

  BusStop getEndingBusStop() {
    return endingBusStop;
  }

  int getStopsAway() {
    return leastStops;
  }
}
