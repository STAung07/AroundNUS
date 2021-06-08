// class for ShuttleServiceResult: overarching class
class ShuttleServicesResult {
  final Shuttles shuttlesResult;

  ShuttleServicesResult({
    required this.shuttlesResult,
  });

  factory ShuttleServicesResult.fromJson(Map<String, dynamic> parsedJson) {
    var shuttleServices =
        parsedJson['ShuttleServiceResult'] as Map<String, dynamic>;
    print(shuttleServices.runtimeType);
    return ShuttleServicesResult(
      shuttlesResult: Shuttles.fromJson(shuttleServices),
    );
  }
}

// list of shuttle services available at current bus stop
class Shuttles {
  final String caption;
  final String busStopName;
  final String timeStamp;
  final List<ArrivalInformation> shuttles;

  Shuttles({
    required this.caption,
    required this.busStopName,
    required this.timeStamp,
    required this.shuttles,
  });

  factory Shuttles.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['shuttles'] as List;
    print(list.runtimeType);
    List<ArrivalInformation> arrivalInfoList =
        list.map((i) => ArrivalInformation.fromJson(i)).toList();

    return Shuttles(
      caption: parsedJson['caption'],
      busStopName: parsedJson['name'],
      timeStamp: parsedJson['TimeStamp'],
      shuttles: arrivalInfoList,
    );
  }
}

// arrival info of current shuttle service
class ArrivalInformation {
  final String arrivalTime;
  final String name;
  final String nextArrivalTime;
  final String nextPassengers;
  final String passengers;
  final String arrivalTimeVehPlate;
  final String nextArrivalTimeVehPlate;

  ArrivalInformation({
    required this.arrivalTime,
    required this.name,
    required this.nextArrivalTime,
    required this.nextPassengers,
    required this.passengers,
    required this.arrivalTimeVehPlate,
    required this.nextArrivalTimeVehPlate,
  });

  factory ArrivalInformation.fromJson(Map<String, dynamic> parsedJson) {
    return ArrivalInformation(
      arrivalTime: parsedJson['arrivalTime'],
      name: parsedJson['name'],
      nextArrivalTime: parsedJson['nextArrivalTime'],
      nextPassengers: parsedJson['nextPassengers'],
      passengers: parsedJson['passengers'],
      arrivalTimeVehPlate: parsedJson['arrivalTime_veh_plate'],
      nextArrivalTimeVehPlate: parsedJson['nextArrivalTime_veh_plate'],
    );
  }
}

class BusServicesTile {
  final String currBusStop;
  final List<ArrivalInformation> servicesInformation;

  BusServicesTile({
    required this.currBusStop,
    required this.servicesInformation,
  });
}
