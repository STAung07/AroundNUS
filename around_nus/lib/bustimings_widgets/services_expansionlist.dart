import 'package:flutter/material.dart';
import '../models/busserviceinfo_model.dart';
import '../services/nusnextbus_service.dart';

class BusServicesAtStop extends StatefulWidget {
  final String busStopName;
  final String displayName;
  /*
  const BusServicesAtStop({Key? key, required this.busStopName})
      : super(key: key);
      */
  const BusServicesAtStop({
    required this.busStopName,
    required this.displayName,
  });

  @override
  _BusServicesAtStopState createState() => _BusServicesAtStopState();
}

class _BusServicesAtStopState extends State<BusServicesAtStop> {
  final busService = NusNextBus();
  List<ArrivalInformation> _currBusStopServices = <ArrivalInformation>[];

  void _updateShuttleServicesInfo(String _busStopName) {
    // each busStop has their own list of ArrivalInformaton
    busService.fetchArrivalInfo(_busStopName).then((value) {
      setState(() {
        _currBusStopServices.addAll(value);
      });
    });
  }

  @override
  void initState() {
    _updateShuttleServicesInfo(widget.busStopName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.displayName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Route",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      "Arrival Timing",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      "Next Arrival Timing",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _currBusStopServices.length,
              itemBuilder: (_, busServicesIndex) {
                // card of row of info
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _currBusStopServices[busServicesIndex].name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(_currBusStopServices[busServicesIndex]
                              .arrivalTime),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(_currBusStopServices[busServicesIndex]
                              .nextArrivalTime),
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
