import 'package:around_nus/models/busserviceinfo_model.dart';
import 'package:flutter/material.dart';
import '../models/pickuppointinfo_model.dart';
import '../services/nusnextbus_service.dart';

class PickUpPointsOfRoute extends StatefulWidget {
  final String busRouteName;
  const PickUpPointsOfRoute({Key? key, required this.busRouteName})
      : super(key: key);

  @override
  _PickUpPointsOfRouteState createState() => _PickUpPointsOfRouteState();
}

class _PickUpPointsOfRouteState extends State<PickUpPointsOfRoute> {
  final busService = NusNextBus();
  List<PickUpPointInfo> _currBusRouteStops = [];
  Map<String, String> finalMap = {};

  void _updateRoutePickUpPointInfo(String _busRouteName) {
    busService.fetchPickUpPointInfo(_busRouteName).then((value) {
      setState(() {
        _currBusRouteStops.addAll(value);
      });
    });
  }

  // from each pickuppoint along route, get arrival timings using busStopCode
  _getMap() {
    _getArrivalTimings().then((value) {
      setState(() {
        finalMap.addAll(value);
      });
    });
  }

  Future<Map<String, String>> _getArrivalTimings() async {
    Map<String, String> busTimingsAtStop = {};
    print(widget.busRouteName);
    List<PickUpPointInfo> currBusRouteStops =
        await busService.fetchPickUpPointInfo(widget.busRouteName);
    print("Pick Up Points");
    for (var busStop in currBusRouteStops) {
      // get list of bus services of curr BusStop in pickuppoint
      String currBusStopName = busStop.busStopCode;
      print(currBusStopName);
      List<ArrivalInformation> currBusStopServices =
          await busService.fetchArrivalInfo(currBusStopName);
      print(currBusStopServices);
      for (var route in currBusStopServices) {
        if (route.name.contains(widget.busRouteName)) {
          // add busstop name and arrival time to map
          busTimingsAtStop[currBusStopName] = route.arrivalTime;
          print(busTimingsAtStop[currBusStopName]);
        }
      }
    }
    print(busTimingsAtStop);
    return busTimingsAtStop;
  }

  @override
  void initState() {
    super.initState();
    _updateRoutePickUpPointInfo(widget.busRouteName);
    print(_currBusRouteStops);
    _getMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.busRouteName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _currBusRouteStops.length,
              itemBuilder: (_, stopIndex) {
                return Card(
                  // dispay just pickuppoint for now
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // busstopname display
                        Expanded(
                          flex: 8,
                          child: Text(
                            _currBusRouteStops[stopIndex].busStopCode,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // timing of route at curr stop; replace with actual time later
                        Expanded(
                          flex: 2,
                          child: Text /*('Null'),*/
                              (finalMap[
                                      _currBusRouteStops[stopIndex].busStopCode]
                                  .toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
