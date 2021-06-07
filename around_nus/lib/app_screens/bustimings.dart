import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import 'dart:convert';

// load json assets
Future<String> _loadBusStopInfoFromAsset() async {
  return await rootBundle.loadString("busstopsresult.json");
}

Future<String> _loadBusRoutesInfoFromAsset() async {
  return await rootBundle.loadString("busroutesresult.json");
}

Future<List<BusStop>> fetchBusStopInfo() async {
  /*
  String username = 'NUSnextbus';
  String password = '13dL?zY,3feWR^"T';
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  var response = await http.get(
      Uri.parse('https://nnextbus.nus.edu.sg/BusStops'),
      headers: <String, String>{'authorization': basicAuth});
  */
  String jsonString = await _loadBusStopInfoFromAsset();
  // get busStopResults
  //var busStopsResult;
  //List<BusStop> busStopList = <BusStop>[];

  //if (response.statusCode == 200) {
  var busStopsResultJson = json.decode(jsonString); //response.body);
  //busStopsResult = BusStopsResult.fromJson(busStopsResultJson);
  // get list of busStops by accessing BusStops class busStopResult
  // and List<BusStop> busStops
  //List<BusStop> busStopList = (busStopsResult).busStopResult.busStops;
  List<BusStop> busStopList = (BusStops.fromJson(busStopsResultJson)).busStops;
  return busStopList;
}

Future<List<RouteDescription>> fetchBusRouteDescriptions() async {
  /*  
   String username = 'NUSnextbus';
   String password = '13dL?zY,3feWR^"T';
   String basicAuth =
       'Basic ' + base64Encode(utf8.encode('$username:$password'));
   var response = await http.get(
       Uri.parse('https://nnextbus.nus.edu.sg/BusStops'),
       headers: <String, String>{'authorization': basicAuth});
   */
  String jsonString = await _loadBusRoutesInfoFromAsset();
  // get busStopResults
  //var busStopsResult;
  //List<BusStop> busStopList = <BusStop>[];

  //if (response.statusCode == 200) {
  var busRoutesResultJson = json.decode(jsonString); //response.body);
  //busStopsResult = BusStopsResult.fromJson(busStopsResultJson);
  // get list of busStops by accessing BusStops class busStopResult
  // and List<BusStop> busStops
  //List<BusStop> busStopList = (busStopsResult).busStopResult.busStops;
  List<RouteDescription> busRoutesList =
      (BusRoutes.fromJson(busRoutesResultJson)).busRoutes;
  return busRoutesList;
}

class BusTimings extends StatefulWidget {
  @override
  _BusTimingsState createState() => _BusTimingsState();
}

class _BusTimingsState extends State<BusTimings> {
  // List of Bus Stops Info & List of Bus Routes Info;
  // passed into required widgets to use information inside
  List<BusStop> _nusBusStops = <BusStop>[];
  List<RouteDescription> _nusBusRoutes = <RouteDescription>[];

  void _updateListofBusStop() {
    fetchBusStopInfo().then((value) {
      setState(() {
        _nusBusStops.addAll(value);
      });
    });
  }

  void _updateListofBusRoutes() {
    fetchBusRouteDescriptions().then((value) {
      setState(() {
        _nusBusRoutes.addAll(value);
      });
    });
  }

  @override
  void initState() {
    _updateListofBusStop();
    _updateListofBusRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Bus Timings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: ListView.builder(
        itemCount: _nusBusStops.length,
        itemBuilder: (context, index) {
          return Text(
            _nusBusStops[index].name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
          // Text(_nusBusStops[index].caption),
          // Text('Bus Stop Position: '),
          // Text('Latitude: ' +
          //     (_nusBusStops[index].latitude).toString()),
          // Text('Longitude: ' +
          //     (_nusBusStops[index].longitude).toString()),
        },
        // itemCount: _nusBusStops.length,
      ),
    );
  }
}
