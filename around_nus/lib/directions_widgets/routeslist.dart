import 'package:around_nus/directions_widgets/displaydirections.dart';
import 'package:around_nus/directions_widgets/pathfindingalgo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RoutesList extends StatefulWidget {
  final String startAddress;
  final String destinationAddress;
  final Position startCoordinates;
  final Position destinationCoordinates;
  final List<PossibleRoutes> routesList;
  const RoutesList({
    Key? key,
    required this.startAddress,
    required this.destinationAddress,
    required this.startCoordinates,
    required this.destinationCoordinates,
    required this.routesList,
  }) : super(key: key);

  @override
  _RoutesListState createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  // create listview of routeslist
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Routes Available'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.routesList.length,
              itemBuilder: (_, routeIndex) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.routesList[routeIndex].routeName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
                        builder: (context) => DirectionsDisplay(
                          startAddress: widget.startAddress,
                          destinationAddress: widget.destinationAddress,
                          startCoordinates: widget.startCoordinates,
                          destinationCoordinates: widget.destinationCoordinates,
                          startBusStop:
                              widget.routesList[routeIndex].startBusStop,
                          endBusStop: widget.routesList[routeIndex].endBusStop,
                          busTaken: widget.routesList[routeIndex].routeName,
                          stopsAway: widget.routesList[routeIndex].stopsBetween,
                        ),
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
