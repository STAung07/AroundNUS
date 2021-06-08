class PickUpPointsResult {
  final PickUpPoints pickUpPointsResult;

  PickUpPointsResult({required this.pickUpPointsResult});

  factory PickUpPointsResult.fromJson(Map<String, dynamic> parsedJson) {
    var pickUpPoints = parsedJson['PickupPointResult'] as Map<String, dynamic>;
    print(pickUpPoints.runtimeType);
    return PickUpPointsResult(
      pickUpPointsResult: PickUpPoints.fromJson(pickUpPoints),
    );
  }
}

class PickUpPoints {
  final List<PickUpPointInfo> pickUpPoints;

  PickUpPoints({
    required this.pickUpPoints,
  });

  factory PickUpPoints.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['pickuppoint'] as List;
    print(list.runtimeType);
    List<PickUpPointInfo> pickUpPointInfoList =
        list.map((i) => PickUpPointInfo.fromJson(i)).toList();
    return PickUpPoints(pickUpPoints: pickUpPointInfoList);
  }
}

class PickUpPointInfo {
  final String pickUpName;
  final int routeId;
  final String busStopCode;
  final double latitude;
  final double longitude;
  final String longName;
  final String shortName;

  PickUpPointInfo({
    required this.pickUpName,
    required this.routeId,
    required this.busStopCode,
    required this.latitude,
    required this.longitude,
    required this.longName,
    required this.shortName,
  });

  factory PickUpPointInfo.fromJson(Map<String, dynamic> parsedJson) {
    return PickUpPointInfo(
      pickUpName: parsedJson['pickupname'],
      routeId: parsedJson['routeid'],
      busStopCode: parsedJson['busstopcode'],
      latitude: parsedJson['lat'],
      longitude: parsedJson['lng'],
      longName: parsedJson['LongName'],
      shortName: parsedJson['ShortName'],
    );
  }
}
