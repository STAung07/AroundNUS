import 'package:flutter/material.dart';
import '../models/busroutesinfo_model.dart';
import '../common_widgets/drawer.dart';
import '../busroutes_widgets/pickuppoints_expansionlist.dart';
import '../services/nusnextbus_service.dart';

class BusRoutes extends StatefulWidget {
  const BusRoutes({Key? key}) : super(key: key);

  @override
  _BusRoutesState createState() => _BusRoutesState();
}

class _BusRoutesState extends State<BusRoutes> {
  final busService = NusNextBus();
  // get list of routes from busroutes info
  List<RouteDescription> _nusBusRoutes = <RouteDescription>[];

  void _updateListofBusRoutes() {
    busService.fetchBusRouteDescriptions().then((value) {
      setState(() {
        _nusBusRoutes.addAll(value);
      });
    });
  }

  @override
  void initState() {
    _updateListofBusRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Bus Routes'),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              // modify or point _nusBusStops at different list
              // based on curr Searched BusStop
              itemCount: _nusBusRoutes.length,
              itemBuilder: (_, routeIndex) {
                // inside each card; call updateshuttleservices info with curr
                // bus stop name from _nusBusStops List
                print(_nusBusRoutes[routeIndex].name);
                //_currBusStopServices = _updateShuttleServicesInfo(_nusBusStops[busIndex].name);
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisSize: MainAxisSize.min,
                      // Create a tile class
                      children: [
                        // Current Bus Stop
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              // Route Name
                              Text(
                                _nusBusRoutes[routeIndex].name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Route Description
                              Text(
                                _nusBusRoutes[routeIndex].routeDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.blue),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickUpPointsOfRoute(
                            busRouteName: _nusBusRoutes[routeIndex].name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
