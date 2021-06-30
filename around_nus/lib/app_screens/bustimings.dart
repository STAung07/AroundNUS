import 'dart:async';
import 'package:flutter/material.dart';
import 'package:around_nus/blocs/application_bloc.dart';
import 'package:provider/provider.dart';
import '../common_widgets/drawer.dart';
import '../models/busroutesinfo_model.dart';
import '../bustimings_widgets/services_expansionlist.dart';
import '../services/nusnextbus_service.dart';

class BusTimings extends StatefulWidget {
  @override
  _BusTimingsState createState() => _BusTimingsState();
}

class _BusTimingsState extends State<BusTimings> {
  // List of Bus Stops Info & List of Bus Routes Info;
  // passed into required widgets to use information inside

  // use Bus Stop Names to display bus services available at that stop
  // List<BusStop> _nusBusStops = <BusStop>[];
  final busService = NusNextBus();
  List<RouteDescription> _nusBusRoutes = <RouteDescription>[];
  //List<PickUpPointInfo> _currPickUpPoints = <PickUpPointInfo>[];
  late StreamSubscription busStopSubscription;
  var _textController = TextEditingController();

  void _updateListofBusRoutes() {
    busService.fetchBusRouteDescriptions().then((value) {
      setState(() {
        _nusBusRoutes.addAll(value);
      });
    });
  }

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    busStopSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {});
    applicationBloc.searchBusStops2("");
    _updateListofBusRoutes();
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    busStopSubscription.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Bus Stops"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                  hintText: "Search Bus Stops ...",
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.clear();
                          applicationBloc.searchBusStops2("");
                        });
                      }),
                  prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                applicationBloc.searchBusStops2(value);
                // getNUSAutoComplete(value);
              },
            ),
          ),
          if (applicationBloc.searchBusStopsResults2 != null)
            Container(
              padding: EdgeInsets.only(top: 70),
              height: 800.0,
              child: ListView.builder(
                itemCount: applicationBloc.searchBusStopsResults2!.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Create a tile class
                        children: [
                          // Current Bus Stop
                          Expanded(
                            child: Text(
                              applicationBloc.searchBusStopsResults2![index],
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
                              busStopName: applicationBloc
                                  .searchBusStopsResults2![index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          /*
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
          */
        ],
      ),
    );
  }
}
