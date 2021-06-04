import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import 'dart:convert';

Future<String> _loadFromAsset() async {
  return await rootBundle.loadString("busstopsresult.json");
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
  String jsonString = await _loadFromAsset();
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
  //}
  return busStopList;
}

class BusTimings extends StatefulWidget {
  @override
  _BusTimingsState createState() => _BusTimingsState();
}

class _BusTimingsState extends State<BusTimings> {
  // used to represent bus stops in ListView
  List<BusStop> _nusBusStops = <BusStop>[];

  @override
  void initState() {
    fetchBusStopInfo().then((value) {
      setState(() {
        _nusBusStops.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Bus Timings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _nusBusStops[index].name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(_nusBusStops[index].caption),
                  Text('Bus Stop Position: '),
                  Text(
                      'Latitude: ' + (_nusBusStops[index].latitude).toString()),
                  Text('Longitude: ' +
                      (_nusBusStops[index].longitude).toString()),
                ],
              ),
            ),
          );
        },
        itemCount: _nusBusStops.length,
      ),
    );
  }
}
