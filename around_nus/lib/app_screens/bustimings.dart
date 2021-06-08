import 'package:flutter/material.dart';
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import '../models/busserviceinfo_model.dart';
import '../models/pickuppointinfo_model.dart';
import '../services/server_request_service.dart';

class BusTimings extends StatefulWidget {
  @override
  _BusTimingsState createState() => _BusTimingsState();
}

class _BusTimingsState extends State<BusTimings> {
  // List of Bus Stops Info & List of Bus Routes Info;
  // passed into required widgets to use information inside

  // use Bus Stop Names to display bus services available at that stop
  List<BusStop> _nusBusStops = <BusStop>[];
  List<RouteDescription> _nusBusRoutes = <RouteDescription>[];
  List<ArrivalInformation> _currBusStopServices = <ArrivalInformation>[];
  List<PickUpPointInfo> _currPickUpPoints = <PickUpPointInfo>[];

  // function that will call fetchArrivalInfo(busStopName) with setState
  // that will be called for each busStop from _nusBusStops
  void _updateShuttleServicesInfo(String _busStopName) {
    // each busStop has their own list of ArrivalInformaton
    //List<ArrivalInformation> _busServices = <ArrivalInformation>[];
    fetchArrivalInfo(_busStopName).then((value) {
      setState(() {
        //_busServices.addAll(value);
        _currBusStopServices.addAll(value);
      });
    });
    //return _busServices;
  }

  void _updatePickUpPointsInfo(String _routeName) {
    fetchPickUpPointInfo(_routeName).then((value) {
      setState(() {
        _currPickUpPoints.addAll(value);
      });
    });
  }

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
    _updatePickUpPointsInfo("A2");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Bus Timings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _currPickUpPoints.length,
              itemBuilder: (_, busIndex) {
                // inside each card; call updateshuttleservices info with curr
                // bus stop name from _nusBusStops List
                //_currBusStopServices =
                //_updateShuttleServicesInfo(_nusBusStops[busIndex].name);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      // Create a tile class
                      children: <Widget>[
                        // Current Bus Stop
                        Text(
                          _currPickUpPoints[busIndex].pickUpName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // ListView of all Bus Services
                        /*
                        Flexible(
                          fit: FlexFit.loose,
                          child: ListView.builder(
                            shrinkWrap: true, //_currBusStopServices.length,
                            itemCount: _currBusStopServices.length,
                            itemBuilder: (_, busServicesIndex) {
                              // each card is for each service at the bus stop
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  // Row of information
                                  // Bus Service name, arrivalTime and nextArrivalTime
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        _currBusStopServices[busServicesIndex]
                                            .name,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          _currBusStopServices[busServicesIndex]
                                              .arrivalTime),
                                      Text(
                                          _currBusStopServices[busServicesIndex]
                                              .nextArrivalTime),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        */
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
