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
      required this.busTaken})
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
            widget.endBusStop.latitude,
            widget.endBusStop.longitude)
        .round();
    int endWalkDistance = _coordinatedistance(
            widget.endBusStop.latitude,
            widget.endBusStop.longitude,
            widget.destinationCoordinates.latitude,
            widget.destinationCoordinates.longitude)
        .round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Directions"),
      ),
      body: Stack(children: [
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
        //first box for walking
        Positioned(
            top: 150,
            left: 20,
            child: Container(
              width: 50,
              height: 25,
              color: Colors.blue,
              child: Text((startWalkDistance / 74).round().toString() + " min",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              alignment: Alignment.center,
            )),
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
            top: 270,
            left: 20,
            child: Container(
              width: 50,
              height: 25,
              color: Colors.blue,
              child: Text("X min",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              alignment: Alignment.center,
            )),
        Positioned(
            top: 260,
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
                    " in about XX min" +
                    ". Alight at " +
                    widget.endBusStop.name +
                    ", " +
                    widget.endBusStop.longName.toString() +
                    ", XX stops later."),
                alignment: Alignment.centerLeft,
              )
            ])),

        //third box for walking
        Positioned(
            top: 390,
            left: 20,
            child: Container(
              width: 50,
              height: 25,
              color: Colors.blue,
              child: Text((endWalkDistance / 74).round().toString() + " min",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              alignment: Alignment.center,
            )),
        Positioned(
            top: 380,
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
                child: Text("Walk to " +
                    widget.endBusStop.name +
                    " bus stop at " +
                    widget.endBusStop.longName.toString() +
                    "."),
                alignment: Alignment.centerLeft,
              )
            ])),
      ]),
    );
  }
}
