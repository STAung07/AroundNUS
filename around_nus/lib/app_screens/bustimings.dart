import 'package:flutter/material.dart';
import '../common_widgets/drawer.dart';
import '../models/busstopsinfo_model.dart';
import '../models/busroutesinfo_model.dart';
import '../models/busserviceinfo_model.dart';
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

  // test
  List<ArrivalInformation> _biz2BusArrivals = <ArrivalInformation>[];

  // function that will call fetchArrivalInfo(busStopName) with setState
  // that will be called for each busStop from _nusBusStops
  void _updateShuttleServicesInfo(String _busStopName) {
    // each busStop has their own list of ArrivalInformaton
    /*List<ArrivalInformation> _busServices = <ArrivalInformation>[];*/
    fetchArrivalInfo(_busStopName).then((value) {
      setState(() {
        //_busServices.addAll(value);
        _biz2BusArrivals.addAll(value);
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
    _updateShuttleServicesInfo('BIZ2');
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
          itemCount: _biz2BusArrivals.length,
          itemBuilder: (_, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
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
                    */
                    Text(_biz2BusArrivals[index].name),
                    Text(_biz2BusArrivals[index].arrivalTime),
                    Text(_biz2BusArrivals[index].nextArrivalTime)
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
