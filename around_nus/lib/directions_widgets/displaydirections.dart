import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../app_screens/searchdirections.dart';

class DirectionsDisplay extends StatefulWidget {
  final String startAddress;
  final String destinationAddress;
  final Position startCoordinates;
  final Position destinationCoordinates;

  // final List
  // final String travelMode;
  const DirectionsDisplay(
      {Key? key,
      required this.startAddress,
      required this.destinationAddress,
      required this.startCoordinates,
      required this.destinationCoordinates})
      : super(key: key);

  @override
  _DirectionsDisplayState createState() => _DirectionsDisplayState();
}

class _DirectionsDisplayState extends State<DirectionsDisplay> {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff7285A5),
          title: Text("Directions"),
        ),
        body: Stack(children: [
          Container(
              padding: EdgeInsets.only(top: 70),
              height: 500,
              child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return Container(
                        // height depends on how long the instructions are
                        height: 100,
                        color: Colors.blueGrey,
                        child: Row(children: [
                          Text("{time needed}"),
                          Column(children: [
                            Text("{travelMode}", textAlign: TextAlign.center),
                            Text("{travelDirections}")
                          ])
                        ]));
                  }))
        ]));
  }
}
