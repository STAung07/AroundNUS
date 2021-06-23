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

class ConnectedBusStop {
  final String routeName;
  final String busStopName;
  ConnectedBusStop({
    required this.routeName,
    required this.busStopName,
  });
}

class PathFindingAlgo {
  final busService = NusNextBus();
  // Map LatLng of each bus stop to its connected bus stops

  // adjList function not working; probably cause of future info fetched from
  // server using info
  // Try: use map to preprocess and store relevant information

  Map<LatLng, List<ConnectedBusStop>> adjList(List<BusStop> busStops) {
    Map<LatLng, List<ConnectedBusStop>> adjacencyList = {};
    for (int i = 0; i < busStops.length; i++) {
      String currBusStopName = busStops[i].name;
      // LatLng to map List of ConnectedBusStop to
      LatLng currBusStopLatLng =
          LatLng(busStops[i].latitude, busStops[i].longitude);
      // list of connected bus stops to curr Bus Stop
      List<ConnectedBusStop> listConnectedBusStops = [];
      List<ArrivalInformation> servicesAtCurrStop = [];
      busService.fetchArrivalInfo(currBusStopName).then((value) {
        servicesAtCurrStop.addAll(value);
      });
      // for each route passing through currBusStop
      for (int j = 0; j < servicesAtCurrStop.length; j++) {
        String currRoute = servicesAtCurrStop[j].name;
        // get list of PickUpPoints
        List<PickUpPointInfo> pickUpPointsCurrRoute = [];
        busService.fetchPickUpPointInfo(currRoute).then((value) {
          pickUpPointsCurrRoute.addAll(value);
        });
        // for each pickUpPoint along currRoute;
        for (int k = 0; k < pickUpPointsCurrRoute.length; k++) {
          String connectedBusStop = pickUpPointsCurrRoute[k].pickUpName;
          // add as connected BusStop to List<ConnectedBusStop> for currBusStop
          listConnectedBusStops.add(ConnectedBusStop(
              routeName: currRoute, busStopName: connectedBusStop));
        }
      }

      // add key value pair of currBusStopLatLng
      adjacencyList[currBusStopLatLng] = listConnectedBusStops;
    }

    return adjacencyList;
  }

  // function takes in start and end bus stop names
  // function returns shortest route between start and end bus stop
  void _getBusPath(String startBusStopName, String endBusStopName) {}
}
