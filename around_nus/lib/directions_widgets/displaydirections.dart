import 'dart:math';

import 'package:around_nus/models/busstopsinfo_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../app_screens/searchdirections.dart';

class DirectionsDisplay extends StatefulWidget {
  final String startAddress;
  final String destinationAddress;
  final BusStop startBusStop;
  final BusStop endBusStop;
  final Position startCoordinates;
  final Position destinationCoordinates;

  // final List
  // final String travelMode;
  const DirectionsDisplay(
      {Key? key,
      required this.startAddress,
      required this.destinationAddress,
      required this.startCoordinates,
      required this.destinationCoordinates,
      required this.startBusStop,
      required this.endBusStop})
      : super(key: key);

  @override
  _DirectionsDisplayState createState() => _DirectionsDisplayState();
}

class _DirectionsDisplayState extends State<DirectionsDisplay> {
  // final List<String> entries = <String>['A', 'B', 'C'];
  // final List<int> colorCodes = <int>[600, 500, 100];

  double _coordinatedistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * 1000 * asin(sqrt(a)));
  }

  @override
  Widget build(BuildContext context) {
    double startWalkDistance = double.parse((_coordinatedistance(
            widget.startCoordinates.latitude,
            widget.startCoordinates.longitude,
            widget.endBusStop.latitude,
            widget.endBusStop.longitude))
        .toStringAsFixed(1));
    double endWalkDistance = _coordinatedistance(
        widget.endBusStop.latitude,
        widget.endBusStop.longitude,
        widget.destinationCoordinates.latitude,
        widget.destinationCoordinates.longitude);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff7285A5),
          title: Text("Directions"),
        ),
        body: Stack(children: [
          Container(
              padding: EdgeInsets.only(top: 70),
              height: 500,
              // child: ListView.builder(
              //     itemCount: 3,
              //     itemBuilder: (context, index) {
              //       return Container(
              //           // height depends on how long the instructions are
              //           height: 100,
              //           color: Colors.blueGrey,
              //           child: Row(children: [
              //             Text("{time needed}"),
              //             Column(children: [
              //               Text("{travelMode}", textAlign: TextAlign.center),
              //               Text("{travelDirections}")
              //             ])
              //           ]));
              //     })
              child: ListView(
                children: [
                  Row(children: [
                    Text((startWalkDistance / 74).round().toString() + "min"),
                    Column(children: [
                      Text("Walk " + startWalkDistance.toString() + "m",
                          textAlign: TextAlign.center),
                      Text("Walk to " + widget.startBusStop.caption.toString())
                    ])
                  ])
                ],
              ))
        ]));
  }
}
