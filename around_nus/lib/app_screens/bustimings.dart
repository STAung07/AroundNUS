import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import 'dart:convert';

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
    //var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Bus Timings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body:
          //ListView.separated(
          //  itemCount: _nusBusStops.length,
          //  itemBuilder: (_, index) => Text(_nusBusStops[index].caption),
          //  separatorBuilder: (_, index) => Divider(),
          Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
          itemCount: _nusBusStops.length,
          itemBuilder: (_, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nusBusStops[index].name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    //Text(_nusBusRoutes[index].routeDescription),
                    Text('Bus Stop Position: '),
                    Text('Latitude: ' +
                        (_nusBusStops[index].latitude).toString()),
                    Text('Longitude: ' +
                        (_nusBusStops[index].longitude).toString()),
                  ],
                ),
              ),
            );
          },
        ))
      ]),
      //),
    );
  }
}
