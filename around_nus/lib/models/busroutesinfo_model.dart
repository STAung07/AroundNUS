class BusRoutesResult {
  final BusRoutes busRoutesResult;

  BusRoutesResult({required this.busRoutesResult});

  factory BusRoutesResult.fromJson(Map<String, dynamic> parsedJson) {
    var busRoutes =
        parsedJson['ServiceDescriptionResult'] as Map<String, dynamic>;
    print(busRoutes.runtimeType);
    return BusRoutesResult(busRoutesResult: BusRoutes.fromJson(busRoutes));
  }
}

class BusRoutes {
  final List<RouteDescription> busRoutes;

  BusRoutes({required this.busRoutes});

  factory BusRoutes.fromJson(Map<String, dynamic> parsedJson) {
    // return list of RouteDescription
    var list = parsedJson['ServiceDescription'] as List;
    print(list.runtimeType);
    List<RouteDescription> busRoutesList =
        list.map((i) => RouteDescription.fromJson(i)).toList();

    return BusRoutes(busRoutes: busRoutesList);
  }
}

class RouteDescription {
  final String name;
  final String routeDescription;

  RouteDescription({required this.name, required this.routeDescription});

  factory RouteDescription.fromJson(Map<String, dynamic> parsedJson) {
    return RouteDescription(
        name: parsedJson['Route'],
        routeDescription: parsedJson['RouteDescription']);
  }
}
