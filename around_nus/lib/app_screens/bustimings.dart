import 'package:flutter/material.dart';
import '../common_widgets/drawer.dart';

//import 'package:nus_nextbus_api/nus_nextbus_api.dart';
//import 'package:nus_nextbus_api/src/models/BusStopsApi.dart';
//import 'package:nus_nextbus_api/src/models/RouteApi.dart';
//import 'package:nus_nextbus_api/src/models/ShuttlesApi.dart';
class BusTimings extends StatefulWidget {
  @override
  _BusTimingsState createState() => _BusTimingsState();
}

class _BusTimingsState extends State<BusTimings> {
//  var nextBusApi = NusNextBusApi();
//  void _getMuseumBusTimings() async {
//    ShuttlesApi shuttles = await nextBusApi.getShuttleTimings("MUSEUM");
//    print(shuttles.shuttles);
//  }

  //@override
  //void initState() {
  //  super.initState();
  //  //_getMuseumBusTimings();
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Bus Timings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back"),
        ),
      ),
    );
  }
}
