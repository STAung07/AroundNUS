// BusStopsResults is map of string to BusStops
/*
class BusStopsResult {
  final BusStops busStopResult;

  BusStopsResult({required this.busStopResult});

  factory BusStopsResult.fromJson(Map<String, dynamic> parsedJson) {
    var busStops = parsedJson['BusStopsResult'] as Map<String, dynamic>;
    return BusStopsResult(busStopResult: BusStops.fromJson(busStops));
  }
}
*/

// BusStops is List of BusStop
class BusStops {
  final List<BusStop> busStops;

  BusStops({required this.busStops});

  factory BusStops.fromJson(Map<String, dynamic> parsedJson) {
    // return list of BusStop
    var list = parsedJson['busstops'] as List;
    print(list.runtimeType);
    List<BusStop> busStopsList = list.map((i) => BusStop.fromJson(i)).toList();

    return BusStops(busStops: busStopsList);
  }
}

// For list map<string, objects> for bus stop info
class BusStop {
  final String caption;
  final double latitude;
  final double longitude;
  final String name;
  final String longName;
  final String shortName;

  BusStop({
    required this.caption,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.longName,
    required this.shortName,
  });

  factory BusStop.fromJson(Map<String, dynamic> parsedJson) {
    return BusStop(
      caption: parsedJson['caption'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude'],
      name: parsedJson['name'],
      longName: parsedJson['LongName'],
      shortName: parsedJson['ShortName'],
    );
  }
}
