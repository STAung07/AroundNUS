import 'package:flutter/material.dart';
import '../models/pickuppointinfo_model.dart';
import '../services/nusnextbus_service.dart';

class PickUpPointsOfRoute extends StatefulWidget {
  final String busRouteName;
  const PickUpPointsOfRoute({Key? key, required this.busRouteName})
      : super(key: key);

  @override
  _PickUpPointsOfRouteState createState() => _PickUpPointsOfRouteState();
}

class _PickUpPointsOfRouteState extends State<PickUpPointsOfRoute> {
  final busService = NusNextBus();
  List<PickUpPointInfo> _currBusRouteStops = [];

  void _updateRoutePickUpPointInfo(String _busRouteName) {
    busService.fetchPickUpPointInfo(_busRouteName).then((value) {
      setState(() {
        _currBusRouteStops.addAll(value);
      });
    });
  }

  // from each pickuppoint along route, get arrival timings using busStopCode

  @override
  void initState() {
    _updateRoutePickUpPointInfo(widget.busRouteName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.busRouteName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _currBusRouteStops.length,
              itemBuilder: (_, stopIndex) {
                return Card(
                  // dispay just pickuppoint for now
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // busstopname display
                        Expanded(
                          flex: 8,
                          child: Text(
                            _currBusRouteStops[stopIndex].pickUpName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // timing of route at curr stop; replace with actual time later
                        Expanded(
                          flex: 2,
                          child: Text('0'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
