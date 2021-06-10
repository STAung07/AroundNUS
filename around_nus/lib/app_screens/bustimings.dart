import 'package:flutter/material.dart';
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import '../models/pickuppointinfo_model.dart';
import '../bustimings_widgets/services_expansionlist.dart';
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
  List<PickUpPointInfo> _currPickUpPoints = <PickUpPointInfo>[];
  //late StreamSubscription busStopSubscription;

  void _updatePickUpPointsInfo(String _routeName) {
    fetchPickUpPointInfo(_routeName).then((value) {
      setState(() {
        _currPickUpPoints.addAll(value);
      });
    });
  }

  // void _updateListofBusStop() {
  //   fetchBusStopInfo(s).then((value) {
  //     setState(() {
  //       _nusBusStops.addAll(value);
  //     });
  //   });
  // }

  void _updateListofBusRoutes() {
    fetchBusRouteDescriptions().then((value) {
      setState(() {
        _nusBusRoutes.addAll(value);
      });
    });
  }

  @override
  void initState() {
    // _updateListofBusStop();
    _updateListofBusRoutes();
    //_updatePickUpPointsInfo("A2");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Bus Stops"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              // modify or point _nusBusStops at different list
              // based on curr Searched BusStop
              itemCount: _nusBusStops.length,
              itemBuilder: (_, busIndex) {
                // inside each card; call updateshuttleservices info with curr
                // bus stop name from _nusBusStops List
                print(_nusBusStops[busIndex].name);
                //_currBusStopServices = _updateShuttleServicesInfo(_nusBusStops[busIndex].name);
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
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
                          child: Text(
                            _nusBusStops[busIndex].name,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
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
                            builder: (context) => BusServicesAtStop(
                                busStopName: _nusBusStops[busIndex].name)));
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
