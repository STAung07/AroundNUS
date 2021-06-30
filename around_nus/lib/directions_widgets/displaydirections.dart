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
  final String busTaken;
  final int stopsAway;

  // final List
  // final String travelMode;
  const DirectionsDisplay(
      {Key? key,
      required this.startAddress,
      required this.destinationAddress,
      required this.startCoordinates,
      required this.destinationCoordinates,
      required this.startBusStop,
      required this.endBusStop,
      required this.busTaken,
      required this.stopsAway})
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
    int startWalkDistance = _coordinatedistance(
            widget.startCoordinates.latitude,
            widget.startCoordinates.longitude,
            widget.startBusStop.latitude,
            widget.startBusStop.longitude)
        .round();
    int endWalkDistance = _coordinatedistance(
            widget.endBusStop.latitude,
            widget.endBusStop.longitude,
            widget.destinationCoordinates.latitude,
            widget.destinationCoordinates.longitude)
        .round();

    int startWalkTimeTaken = (startWalkDistance / 74).round();
    int endWalkTimeTaken = (endWalkDistance / 74).round();
    int busTimeTaken = (widget.stopsAway * 2);

    double dy = 0;

    if (widget.startAddress == widget.startBusStop.longName) {
      dy += 120;
    }
    // if (widget.destinationAddress == widget.endBusStop.longName) {
    //   indexCount -= 1;
    // }

    print("the start address is:");
    print(widget.startAddress);
    print("the start bus stop long name is: ");
    print(widget.startBusStop.longName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Directions"),
      ),
      body: Stack(children: <Widget>[
        //background
        Positioned(
            top: 125,
            left: 10,
            // height: 250,
            // width: 250,
            child: Container(
              width: 390,
              height: 500,
              color: Colors.grey[200],
            )),

        //top box for total time taken
        Positioned(
            top: 20,
            left: 20,
            child: Column(children: [
              Container(
                width: 150,
                height: 40,
                color: Colors.grey[200],
                child: Text("Total Time:",
                    style: TextStyle(
                      color: Colors.black,
                    )),
                alignment: Alignment.center,
              ),
              Container(
                width: 150,
                height: 40,
                color: Colors.blue,
                child: Text(
                    (startWalkTimeTaken + endWalkTimeTaken + busTimeTaken)
                            .toString() +
                        " min",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
                alignment: Alignment.center,
              )
            ])),

        //first box for walking
        if (widget.startAddress != widget.startBusStop.longName)
          Positioned(
              top: 150,
              left: 20,
              child: Container(
                width: 50,
                height: 25,
                color: Colors.blue,
                child: Text(startWalkTimeTaken.toString() + " min",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                alignment: Alignment.center,
              )),
        if (widget.startAddress != widget.startBusStop.longName)
          Positioned(
              top: 140,
              left: 90,
              height: 120,
              width: 300,
              child: Column(children: [
                Container(
                    // color: Colors.red,
                    child: Text("Walk " + startWalkDistance.toString() + " m",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    alignment: Alignment.bottomLeft),
                Container(
                  child: Text("Walk to " +
                      widget.startBusStop.name +
                      " bus stop at " +
                      widget.startBusStop.longName.toString() +
                      "."),
                  alignment: Alignment.centerLeft,
                )
              ])),

        // second box for bus path
        Positioned(
            top: 270 - dy,
            left: 20,
            child: Container(
              width: 50,
              height: 25,
              color: Colors.blue,
              child: Text(busTimeTaken.toString() + " min",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              alignment: Alignment.center,
            )),
        Positioned(
            top: 260 - dy,
            left: 90,
            height: 120,
            width: 300,
            child: Column(children: [
              Container(
                  // color: Colors.red,
                  child: Text("Bus " + widget.busTaken,
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  alignment: Alignment.bottomLeft),
              Container(
                child: Text("Board at " +
                    widget.startBusStop.name +
                    ", " +
                    widget.startBusStop.longName.toString() +
                    //" in about XX min" +
                    ". Alight at " +
                    widget.endBusStop.name +
                    " Bus Stop, " +
                    widget.endBusStop.longName.toString() +
                    ", " +
                    widget.stopsAway.toString() +
                    " stops later."),
                alignment: Alignment.centerLeft,
              )
            ])),

        //third box for walking
        if (widget.destinationAddress != widget.endBusStop.longName)
          Positioned(
              top: 390 - dy,
              left: 20,
              child: Container(
                width: 50,
                height: 25,
                color: Colors.blue,
                child: Text(endWalkTimeTaken.toString() + " min",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                alignment: Alignment.center,
              )),
        if (widget.destinationAddress != widget.endBusStop.longName)
          Positioned(
              top: 380 - dy,
              left: 90,
              height: 120,
              width: 300,
              child: Column(children: [
                Container(
                    // color: Colors.red,
                    child: Text("Walk " + endWalkDistance.toString() + " m",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    alignment: Alignment.bottomLeft),
                Container(
                  child: Text("Walk to " + widget.destinationAddress + "."),
                  alignment: Alignment.centerLeft,
                )
              ])),
      ]),
    );
  }
}
