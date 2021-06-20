class CheckPointResult {
  final CheckPoints checkPointsResult;

  CheckPointResult({
    required this.checkPointsResult,
  });

  factory CheckPointResult.fromJson(Map<String, dynamic> parsedJson) {
    var checkPoints = parsedJson['CheckPointResult'] as Map<String, dynamic>;
    return CheckPointResult(
      checkPointsResult: CheckPoints.fromJson(checkPoints),
    );
  }
}

class CheckPoints {
  final List<CheckPointInfo> checkpoints;

  CheckPoints({
    required this.checkpoints,
  });

  factory CheckPoints.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['CheckPoint'] as List;
    List<CheckPointInfo> checkPointInfoList =
        list.map((i) => CheckPointInfo.fromJson(i)).toList();
    return CheckPoints(
      checkpoints: checkPointInfoList,
    );
  }
}

class CheckPointInfo {
  final double longitude;
  final double latitude;
  final String pointId;
  final int routeId;

  CheckPointInfo({
    required this.longitude,
    required this.latitude,
    required this.pointId,
    required this.routeId,
  });

  factory CheckPointInfo.fromJson(Map<String, dynamic> parsedJson) {
    return CheckPointInfo(
      longitude: parsedJson['longitude'],
      latitude: parsedJson['latitude'],
      pointId: parsedJson['PointID'],
      routeId: parsedJson['routeid'],
    );
  }
}
