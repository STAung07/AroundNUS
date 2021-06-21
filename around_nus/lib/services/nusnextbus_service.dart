import 'package:around_nus/models/pickuppointinfo_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import '../models/busserviceinfo_model.dart';
import '../models/checkpointinfo_model.dart';

class NusNextBus {
// Request for List of Bus Stop
  Future<List<BusStop>> fetchBusStopInfo() async {
    String username = 'NUSnextbus';
    String password = '13dL?zY,3feWR^"T';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.get(
        Uri.parse('https://nnextbus.nus.edu.sg/BusStops'),
        headers: <String, String>{'authorization': basicAuth});
    // get busStopResults
    var busStopsResult;
    List<BusStop> busStopList = <BusStop>[];

    if (response.statusCode == 200) {
      var busStopsResultJson = json.decode(response.body);
      busStopsResult = BusStopsResult.fromJson(busStopsResultJson);
      // get list of busStops by accessing BusStopsResult class busStopResult
      // and List<BusStop> busStops
      busStopList = (busStopsResult).busStopResult.busStops;
    }
    return busStopList;
  }

  Future<List> autoCompleteBusStops(search) async {
    List<BusStop> busStopList = await fetchBusStopInfo();
    var results = [];
    for (int i = 0; i < busStopList.length; i++) {
      if (busStopList[i].name.toLowerCase().contains(search.toLowerCase())) {
        results.add(busStopList[i].name);
      }
    }
    return results;
  }

// Call in bustimings.dart depending on current bus stop name / caption
// request for bus timings at each bus stop
  Future<List<ArrivalInformation>> fetchArrivalInfo(String _busStopName) async {
    String username = 'NUSnextbus';
    String password = '13dL?zY,3feWR^"T';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.get(
        Uri.parse(
            'https://nnextbus.nus.edu.sg/ShuttleService?busstopname=$_busStopName'),
        headers: <String, String>{'authorization': basicAuth});
    var shuttleServicesResults;
    List<ArrivalInformation> arrivalInfoList = <ArrivalInformation>[];

    if (response.statusCode == 200) {
      var shuttleServicesResultsJson = json.decode(response.body);
      shuttleServicesResults =
          ShuttleServicesResult.fromJson(shuttleServicesResultsJson);
      arrivalInfoList = (shuttleServicesResults).shuttlesResult.shuttles;
    }
    return arrivalInfoList;
  }

// Request for list of Routes
  Future<List<RouteDescription>> fetchBusRouteDescriptions() async {
    String username = 'NUSnextbus';
    String password = '13dL?zY,3feWR^"T';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.get(
        Uri.parse('https://nnextbus.nus.edu.sg/ServiceDescription'),
        headers: <String, String>{'authorization': basicAuth});
    // get busRoutesResults
    var busRoutesResults;
    List<RouteDescription> busRoutesList = <RouteDescription>[];

    if (response.statusCode == 200) {
      var busRoutesResultJson = json.decode(response.body);
      busRoutesResults = BusRoutesResult.fromJson(busRoutesResultJson);
      // get list of busRoutes by accessing BusRoutesResults class busStopResult
      // and List<RouteDescription> busRoutes
      busRoutesList = (busRoutesResults).busRoutesResult.busRoutes;
    }
    return busRoutesList;
  }

  // when route passed in, able to return all pickup points within route
  Future<List<PickUpPointInfo>> fetchPickUpPointInfo(
      String _busRouteName) async {
    String username = 'NUSnextbus';
    String password = '13dL?zY,3feWR^"T';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.get(
        Uri.parse(
            'https://nnextbus.nus.edu.sg/PickupPoint?route_code=$_busRouteName'),
        headers: <String, String>{'authorization': basicAuth});
    var pickUpPointResults;
    List<PickUpPointInfo> pickUpPointInfoList = <PickUpPointInfo>[];

    if (response.statusCode == 200) {
      var pickUpPointResultsJson = json.decode(response.body);
      pickUpPointResults = PickUpPointsResult.fromJson(pickUpPointResultsJson);
      pickUpPointInfoList =
          (pickUpPointResults).pickUpPointsResult.pickUpPoints;
    }
    return pickUpPointInfoList;
  }

  // when route passsed in able to return checkpoints of route; get waypoints
  Future<List<CheckPointInfo>> fetchCheckPointInfo(String _busRouteName) async {
    String username = 'NUSnextbus';
    String password = '13dL?zY,3feWR^"T';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.get(
        Uri.parse(
            'https://nnextbus.nus.edu.sg/CheckPoint?route_code=$_busRouteName'),
        headers: <String, String>{'authorization': basicAuth});
    var checkPointResults;
    List<CheckPointInfo> checkPointInfoList = <CheckPointInfo>[];

    if (response.statusCode == 200) {
      var checkPointResultsJson = json.decode(response.body);
      checkPointResults = CheckPointResult.fromJson(checkPointResultsJson);
      checkPointInfoList = (checkPointResults).checkPointsResult.checkpoints;
    }
    return checkPointInfoList;
  }
}
