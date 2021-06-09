import 'package:flutter/material.dart';
import '../models/busserviceinfo_model.dart';
import '../services/server_request_service.dart';

class BusServicesAtStop extends StatefulWidget {
  final String busStopName;
  const BusServicesAtStop({Key? key, required this.busStopName})
      : super(key: key);

  @override
  _BusServicesAtStopState createState() => _BusServicesAtStopState();
}

class _BusServicesAtStopState extends State<BusServicesAtStop> {
  List<ArrivalInformation> _currBusStopServices = <ArrivalInformation>[];

  void _updateShuttleServicesInfo(String _busStopName) {
    // each busStop has their own list of ArrivalInformaton
    fetchArrivalInfo(_busStopName).then((value) {
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
        title: Text(widget.busStopName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
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
                                fontSize: 12, fontWeight: FontWeight.bold),
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
