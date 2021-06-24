import 'dart:async';
import 'dart:typed_data';

import 'package:around_nus/blocs/application_bloc.dart';
import 'package:around_nus/models/busroutesinfo_model.dart';
import 'package:around_nus/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/busstopsinfo_model.dart';
import '../models/pickuppointinfo_model.dart';
import '../models/busserviceinfo_model.dart';
import '../models/checkpointinfo_model.dart';
import '../services/nusnextbus_service.dart';
import 'dart:math'; //show cos, sqrt, asin;
import '../common_widgets/drawer.dart';
import 'dart:convert';
import '../directions_widgets/apikey.dart'; // Stores the Google Maps API Key
import '../directions_widgets/pathfindingalgo.dart';
import 'package:flutter/services.dart' show rootBundle;

class FindDirections extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AroundNUS',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(1.2966, 103.7764), zoom: 14);
  // GoogleMapController? mapController;
  Completer<GoogleMapController> mapController = Completer();
  late GoogleMapController newMapController;
  late StreamSubscription locationSubscription;

  Map nusVenuesData = {};

  Position? _currentPosition;
  String? _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  // Marker startMarker;
  // Marker endMarker;
  Set<Marker> markers = {};

  // polyline points contain coordinates of route to draw on map
  PolylinePoints? polylinePoints;

  // assign polylines to each Map based on button pressed
  // switch between Map based on button pressed
  Map<PolylineId, Polyline> walkingPathPolylines = {};
  Map<PolylineId, Polyline> drivingPathPolylines = {};
  Map<PolylineId, Polyline> hybridPathPolylines = {};
  Map<PolylineId, Polyline> polylines = {};

  // holds each polyline coordinate as Lat and Lng Pairs
  List<LatLng> polylineCoordinates = [];

  // generates every polyline between start and finish

  NusNextBus busService = NusNextBus();
  Map<String, List<ConnectedBusStops>> adjacencyList = {};
  //PathFindingAlgo pathFinder = PathFindingAlgo(adjacencyList: adjacencyList);
  late PathFindingAlgo pathFinder;

  // list of bus stops as possible wayPoint
  List<BusStop> _nusBusStops = [];
  Map<String, Position> _busStopsToPosition = {};
  List<PolylineWayPoint> _wayPoints = [];

  List<bool> _selections = List.generate(3, (_) => false);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _updateMapofBusStop() async {
    _nusBusStops = await busService.fetchBusStopInfo();
    for (var busStop in _nusBusStops) {
      String busStopName = busStop.name;
      Position busStopPos = Position(
        longitude: busStop.longitude,
        latitude: busStop.latitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      _busStopsToPosition[busStopName] = busStopPos;
    }
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        newMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // current version waits for input in search bars of from and to
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress!;
        _startAddress = _currentAddress!;
        _setMarkers(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      });
    } catch (e) {
      print(e);
    }
  }

  // Google Maps SetMarkers; not applicable in OSMview
  Future<void> _setMarkers(LatLng point) async {
    //set starting marker
    markers.clear();
    if (_startAddress.length != 0) {
      print("start address: ");
      print(_startAddress);
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      print("start placemark: ");
      print(startPlacemark[0]);
      Position startCoordinates = Position(
          latitude: startPlacemark[0].latitude,
          longitude: startPlacemark[0].longitude,
          speed: 0.0,
          speedAccuracy: 0.0,
          heading: 0.0,
          altitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0);
      Marker startMarker = Marker(
        markerId: MarkerId('$startCoordinates'),
        position: LatLng(
          startCoordinates.latitude,
          startCoordinates.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Start',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      setState(() {
        markers.add(startMarker);
      });
    }

    if (_destinationAddress.length != 0) {
      print("destination address: ");
      print(_destinationAddress);
      List<Location> endPlacemark =
          await locationFromAddress(_destinationAddress);
      print("destination placemark: ");
      print(endPlacemark[0]);
      Position endCoordinates = Position(
          latitude: endPlacemark[0].latitude,
          longitude: endPlacemark[0].longitude,
          speed: 0.0,
          speedAccuracy: 0.0,
          heading: 0.0,
          altitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0);
      Marker endMarker = Marker(
        markerId: MarkerId('$endCoordinates'),
        position: LatLng(
          endCoordinates.latitude,
          endCoordinates.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      setState(() {
        markers.add(endMarker);
      });
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition!.latitude,
                longitude: _currentPosition!.longitude,
                speed: 0.0,
                speedAccuracy: 0.0,
                heading: 0.0,
                altitude: 0.0,
                timestamp: DateTime.now(),
                accuracy: 0.0)
            : Position(
                latitude: startPlacemark[0].latitude,
                longitude: startPlacemark[0].longitude,
                speed: 0.0,
                speedAccuracy: 0.0,
                heading: 0.0,
                altitude: 0.0,
                timestamp: DateTime.now(),
                accuracy: 0.0);
        Position destinationCoordinates = Position(
            latitude: destinationPlacemark[0].latitude,
            longitude: destinationPlacemark[0].longitude,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0,
            timestamp: DateTime.now(),
            accuracy: 0.0);

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? startCoordinates.latitude
                : destinationCoordinates.latitude;
        double minx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? startCoordinates.longitude
                : destinationCoordinates.longitude;
        double maxy =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? destinationCoordinates.latitude
                : startCoordinates.latitude;
        double maxx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? destinationCoordinates.longitude
                : startCoordinates.longitude;

        _southwestCoordinates = Position(
            latitude: miny,
            longitude: minx,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0,
            timestamp: DateTime.now(),
            accuracy: 0.0);
        _northeastCoordinates = Position(
            latitude: maxy,
            longitude: maxx,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0,
            timestamp: DateTime.now(),
            accuracy: 0.0);

        // Accommodate the two locations within the
        // camera view of the map
        newMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        // switch between diff map of polylines based on button pressed to
        // display diff routes; walking, driving, hybrid

        // get walking + bus route; colour coded yellow and blue
        await _getWalkingAndBusPath(
            startCoordinates, destinationCoordinates, hybridPathPolylines);

        // get walking path; colour coded green
        await _createGoogleMapsPolylines(
          startCoordinates,
          destinationCoordinates,
          Colors.green,
          TravelMode.walking,
          [],
          PolylineId('walking'),
          walkingPathPolylines,
        );

        // get driving path; colour coded red
        await _createGoogleMapsPolylines(
          startCoordinates,
          destinationCoordinates,
          Colors.red,
          TravelMode.driving,
          [],
          PolylineId('driving'),
          drivingPathPolylines,
        );

        double totalDistance = 0.0;

        /*
        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }
        */

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // adjust to account for travel there or back; get accurate start and end
  String _nearestBusStop(Position pos) {
    // distance between pos and first bus stop in list
    double currMinDist = _coordinateDistance(pos.latitude, pos.longitude,
        _nusBusStops[0].latitude, _nusBusStops[0].longitude);

    int currIndex = 0;

    // go through all bus stops; find nearest
    for (int i = 1; i < _nusBusStops.length; i++) {
      double currDist = _coordinateDistance(pos.latitude, pos.longitude,
          _nusBusStops[i].latitude, _nusBusStops[i].longitude);
      if (currDist < currMinDist) {
        currIndex = i;
        currMinDist = currDist;
      }
    }

    return _nusBusStops[currIndex].name;
  }

  // Works; BUT need to constrain waypoints being added, from entire bus route to just
  // parts travelled
  // Use Name to identify PickUpPoints rather than LatLng; double inaccurate
  // Check pickUpName of pickUpPoint with bus stop name of nearest bus stop
  Future<List<PolylineWayPoint>> _getBusWayPoints(
      String _routeName, String start, String end) async {
    List<PolylineWayPoint> wayPoints = [];
    List<PickUpPointInfo> currRoutePickUpPoints =
        await busService.fetchPickUpPointInfo(_routeName);

    print(currRoutePickUpPoints);
    bool isPath = false;

    for (var pickUpPoint in currRoutePickUpPoints) {
      // for each checkpoint, get lat and lng as string and add to waypoint
      String lat = pickUpPoint.latitude.toString();
      String lng = pickUpPoint.longitude.toString();
      if (isPath == true) {
        wayPoints.add(PolylineWayPoint(location: '$lat,$lng', stopOver: true));
      }
      print('Curr Stop');
      print(pickUpPoint.busStopCode);
      print('Start Stop');
      print(start);
      //print(pickUpPoint.pickUpName.toLowerCase() == start.toLowerCase());
      if (pickUpPoint.busStopCode == start) {
        isPath = true;
      }
      print('End Stop');
      print(end);
      //print(pickUpPoint.pickUpName.toLowerCase() == end.toLowerCase());
      if (pickUpPoint.busStopCode == end) {
        isPath = false;
      }
      print(isPath);
    }
    print(wayPoints);
    return wayPoints;
  }

  // Future Map Method for adjacency list
  Future<Map<String, List<ConnectedBusStops>>> adjList(
      List<BusStop> busStops) async {
    Map<String, List<ConnectedBusStops>> adjacencyList = {};
    for (int i = 0; i < busStops.length; i++) {
      String currBusStopName = busStops[i].name;
      // list of connected bus stops to curr Bus Stop
      List<ConnectedBusStops> listConnectedBusStops = [];
      List<ArrivalInformation> servicesAtCurrStop =
          await busService.fetchArrivalInfo(currBusStopName);
      // for each route passing through currBusStop
      for (var services in servicesAtCurrStop) {
        String currRoute = services.name;
        // get list of PickUpPoints for each route
        List<PickUpPointInfo> pickUpPointsCurrRoute =
            await busService.fetchPickUpPointInfo(currRoute);
        // for each pickUpPoint along currRoute;
        // only add BusStops in pickUpPoitnsCurrRoute after currBusStopName
        bool isAfter = false;
        for (var pickUpPoint in pickUpPointsCurrRoute) {
          String connectedBusStop = pickUpPoint.busStopCode;
          // add as connected BusStop to List<ConnectedBusStop> for currBusStop
          int counter = 0;
          if (isAfter) {
            counter++;
            listConnectedBusStops.add(ConnectedBusStops(
                routeName: currRoute,
                busStopName: connectedBusStop,
                stopsAway: counter));
          }
          // once currBusStopname found; make it true
          if (connectedBusStop == currBusStopName) {
            isAfter = true;
          }
        }
      }
      // add key value pair of currBusStopLatLng
      adjacencyList[currBusStopName] = listConnectedBusStops;
    }
    return adjacencyList;
  }

  _getWalkingAndBusPath(
    Position startCoordinates,
    Position destinationCoordinates,
    Map<PolylineId, Polyline> hybridPolyline,
  ) async {
    String startBusStopName = _nearestBusStop(startCoordinates).toString();
    Position startBusStopPos =
        _busStopsToPosition[startBusStopName] as Position;
    print('StartBusStopInfo');
    print(startBusStopName);
    print(startBusStopPos);
    String endBusStopName = _nearestBusStop(destinationCoordinates).toString();
    Position endBusStopPos = _busStopsToPosition[endBusStopName] as Position;
    print('EndBusStopInfo');
    print(endBusStopName);
    print(endBusStopPos);

    // walk to nearest start bus stop
    await _createGoogleMapsPolylines(
      startCoordinates,
      startBusStopPos,
      Colors.yellow,
      TravelMode.walking,
      [],
      PolylineId('toStartBusStop'),
      hybridPolyline,
    );

    print('Walk to start bus stop');

    print(_nusBusStops);
    //_callAdjListFuture();
    adjacencyList = await adjList(_nusBusStops);
    pathFinder = PathFindingAlgo(
      adjacencyList: adjacencyList,
      busStopToPos: _busStopsToPosition,
    );
    print(adjacencyList);
    print(_busStopsToPosition);

    // shortestPath algo which returns shortest bus route to get there
    String shortestPath =
        pathFinder.getBusPath(startBusStopName, endBusStopName);
    print(shortestPath);

    // get wayPoints for route
    _wayPoints = await _getBusWayPoints(
      shortestPath,
      startBusStopName,
      endBusStopName,
    );

    print(_wayPoints);

    ///*
    await _createGoogleMapsPolylines(
      startBusStopPos,
      endBusStopPos,
      Colors.blue,
      TravelMode.driving,
      _wayPoints,
      PolylineId('betweenBusStops'),
      hybridPolyline,
    );
    //*/

    // walking path from end bus stop to end
    await _createGoogleMapsPolylines(
      endBusStopPos,
      destinationCoordinates,
      Colors.yellow,
      TravelMode.walking,
      [],
      PolylineId('fromEndBusStop'),
      hybridPolyline,
    );

    print('Walk from end bus stop to destination');
  }

  // Create the polylines for showing the route between two places
  // Polylines from google
  _createGoogleMapsPolylines(
    Position start,
    Position destination,
    Color colour,
    TravelMode modeOfTravel,
    List<PolylineWayPoint> wayPoints,
    PolylineId id,
    Map<PolylineId, Polyline> currPolyline,
  ) async {
    // initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // reset polylineCoordinates each time called
    polylineCoordinates = [];

    // add wayPoints of start and destination to _wayPoints
    // can add waypoints {bus stops along route}
    PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: modeOfTravel,
      wayPoints: wayPoints,
    );

    // adding coordinates to the list
    // ADJUST / ADD coodinates of NUS shuttle busstops here
    // to be drawn on polyline
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    //PolylineId id = PolylineId('line');
    //Color colour = Colors.blue;

    // initialising Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: colour,
      points: polylineCoordinates,
      width: 3,
    );
    currPolyline[id] = polyline;
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    locationSubscription.cancel();
    startAddressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace(place);
      }
    });
    _getCurrentLocation();
    //_updateListofBusStop();
    _updateMapofBusStop();
    //_callAdjListFuture();
    //pathFinder = PathFindingAlgo(adjacencyList: adjacencyList);
    // default show hybrid path
    polylines = hybridPathPolylines;
    //_updateListofPickUpPoint('D1');
    //_updateListofCheckPoint('D1');
    //_getBusWayPoints('D1');
    this.loadJsonData();
    super.initState();
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/nusvenues.json');

    setState(() {
      nusVenuesData = json.decode(jsonText);
    });
    return "success";
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Directions")),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Container(
        height: height,
        width: width,
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              // GoogleMap View
              GoogleMap(
                markers: Set<Marker>.from(markers),
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                // draws all polyline values in polylines map
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  mapController.complete(controller);
                  newMapController = controller;
                },
              ),
              // Show zoom buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 160.0, left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.blueGrey[100], // button color
                          child: InkWell(
                            splashColor: Colors.white, // inkwell color
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.add),
                            ),
                            onTap: () {
                              newMapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: Colors.blueGrey[100], // button color
                          child: InkWell(
                            splashColor: Colors.white, // inkwell color
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.remove),
                            ),
                            onTap: () {
                              newMapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Show the place input fields & button for
              // showing the route
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      width: width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Enter Start and End location',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            // Getting Starting Location
                            SizedBox(height: 10),
                            Container(
                              width: width * 0.8,
                              child: TextField(
                                onChanged: (value) {
                                  // setState(() {
                                  //   _startAddress = value;
                                  // });
                                  applicationBloc.searchFromPlaces(value);
                                  applicationBloc.searchNUSFromPlaces(value);
                                },
                                controller: startAddressController,
                                focusNode: startAddressFocusNode,
                                decoration: new InputDecoration(
                                  prefixIcon: Icon(Icons.looks_one),
                                  // suffixIcon: IconButton(
                                  //   icon: Icon(Icons.my_location),
                                  //   onPressed: () {
                                  //     startAddressController.text =
                                  //         _currentAddress!;
                                  //     _startAddress = _currentAddress!;
                                  //   },
                                  // ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        startAddressController.clear();
                                      });
                                    },
                                  ),
                                  labelText: "From",
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                  hintText: "Choose Starting Point",
                                ),
                              ),
                            ),
                            // Get Ending Location
                            SizedBox(height: 10),
                            Container(
                              width: width * 0.8,
                              child: TextField(
                                onChanged: (value) {
                                  // setState(() {
                                  //   _destinationAddress = value;
                                  // });
                                  applicationBloc.searchNUSToPlaces(value);
                                  applicationBloc.searchToPlaces(value);
                                },
                                controller: destinationAddressController,
                                focusNode: destinationAddressFocusNode,
                                decoration: new InputDecoration(
                                  prefixIcon: Icon(Icons.looks_two),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        destinationAddressController.clear();
                                      });
                                    },
                                  ),
                                  labelText: "To",
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                  hintText: "Choose Destination",
                                ),
                              ),
                            ),
                            // Distance Calculation
                            SizedBox(height: 10),
                            Visibility(
                              visible: _placeDistance == null ? false : true,
                              child: ToggleButtons(
                                children: <Widget>[
                                  Icon(Icons.nordic_walking),
                                  Icon(Icons.directions_car),
                                  Icon(Icons.directions_bus),
                                ],
                                onPressed: (int index) {
                                  setState(() {
                                    /*
                                    for (int buttonIndex = 0;
                                        buttonIndex < _selections.length;
                                        buttonIndex++) {
                                      if (buttonIndex == index) {
                                        _selections[buttonIndex] = true;
                                      } else {
                                        _selections[buttonIndex] = false;
                                      }
                                    }
                                    */
                                    // if first button pressed; walking path
                                    if (index == 0) {
                                      polylines = walkingPathPolylines;
                                      _selections[0] = true;
                                      _selections[1] = false;
                                      _selections[2] = false;
                                    } else if (index == 1) {
                                      polylines = drivingPathPolylines;
                                      _selections[0] = false;
                                      _selections[1] = true;
                                      _selections[2] = false;
                                    } else {
                                      polylines = hybridPathPolylines;
                                      _selections[0] = false;
                                      _selections[1] = false;
                                      _selections[2] = true;
                                    }
                                    // if second button pressed; driving path
                                    // if third button pressed;
                                  });
                                },
                                isSelected: _selections,
                                // isSelected: isSelected,
                              ),
                              // child: Text(
                              //   'DISTANCE: $_placeDistance km',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ),
                            SizedBox(height: 5),
                            RaisedButton(
                              onPressed: (_startAddress != '' &&
                                      _destinationAddress != '')
                                  ? () async {
                                      startAddressFocusNode.unfocus();
                                      destinationAddressFocusNode.unfocus();
                                      setState(() {
                                        if (markers.isNotEmpty) markers.clear();
                                        if (polylines.isNotEmpty)
                                          polylines.clear();
                                        /*
                                        if (polylineCoordinates.isNotEmpty)
                                          polylineCoordinates.clear();
                                        */
                                        _placeDistance = null;
                                      });

                                      _calculateDistance().then((isCalculated) {
                                        if (isCalculated) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Distance Calculated Sucessfully'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error Calculating Distance'),
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  : null,
                              color: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Show Route'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //SEARCH FROM RESULTS STORED INTO THESE 2 CONTAINERS
              if ((applicationBloc.searchNUSFromResults != null ||
                      applicationBloc.searchFromResults != null) &&
                  (applicationBloc.searchNUSFromResults!.length != 0 ||
                      applicationBloc.searchFromResults!.length != 0) &&
                  startAddressController.text.length != 0)
                Container(
                    margin: EdgeInsets.only(top: 100, right: 40, left: 40),
                    height: 415.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        backgroundBlendMode: BlendMode.darken,
                        color: Colors.black.withOpacity(0.6))),
              if ((applicationBloc.searchNUSFromResults != null ||
                      applicationBloc.searchFromResults != null) &&
                  (applicationBloc.searchNUSFromResults!.length != 0 ||
                      applicationBloc.searchFromResults!.length != 0) &&
                  startAddressController.text.length != 0)
                Container(
                    padding: EdgeInsets.only(top: 100, right: 35, left: 35),
                    height: 415.0,
                    child: ListView.builder(
                        itemCount: (applicationBloc.searchFromResults!.length +
                            applicationBloc.searchNUSFromResults!.length),
                        itemBuilder: (context, index) {
                          if (index <
                              applicationBloc.searchNUSFromResults!.length)
                            return ListTile(
                              title: Text(
                                applicationBloc.searchNUSFromResults![index],
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                //removes inbuilt keyboard
                                FocusScope.of(context).unfocus();
                                //set start address as tapped location
                                setState(() {
                                  _startAddress = nusVenuesData[applicationBloc
                                          .searchNUSFromResults![index]]
                                      ["description"];
                                });
                                //textfield value is selected location
                                startAddressController.value =
                                    startAddressController.value.copyWith(
                                  text: applicationBloc
                                      .searchNUSFromResults![index],
                                  selection: TextSelection.collapsed(
                                      offset: applicationBloc
                                          .searchNUSFromResults![index].length),
                                );
                                // bring camera to selected location
                                _goToNUSPlace(
                                    nusVenuesData[applicationBloc
                                            .searchNUSFromResults![index]]
                                        ["latitude"],
                                    nusVenuesData[applicationBloc
                                            .searchNUSFromResults![index]]
                                        ["longitude"]);

                                applicationBloc.setNUSSelectedLocation();
                              },
                            );
                          else {
                            return ListTile(
                              title: Text(
                                applicationBloc
                                    .searchFromResults![index -
                                        applicationBloc
                                            .searchNUSFromResults!.length]
                                    .description,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _startAddress = applicationBloc
                                      .searchFromResults![index -
                                          applicationBloc
                                              .searchNUSFromResults!.length]
                                      .description;
                                });

                                applicationBloc.setSelectedLocation(
                                    applicationBloc
                                        .searchFromResults![index -
                                            applicationBloc
                                                .searchNUSFromResults!.length]
                                        .placeId);
                                startAddressController.value =
                                    startAddressController.value.copyWith(
                                  text: applicationBloc
                                      .searchFromResults![index -
                                          applicationBloc
                                              .searchNUSFromResults!.length]
                                      .description,
                                  selection: TextSelection.collapsed(
                                      offset: applicationBloc
                                          .searchFromResults![index -
                                              applicationBloc
                                                  .searchNUSFromResults!.length]
                                          .description
                                          .length),
                                );
                              },
                            );
                          }
                        })),

              //SEARCH TO RESULTS STORED INTO THESE TWO CONTAINERS
              if ((applicationBloc.searchNUSToResults != null ||
                      applicationBloc.searchToResults != null) &&
                  (applicationBloc.searchNUSToResults!.length != 0 ||
                      applicationBloc.searchToResults!.length != 0) &&
                  destinationAddressController.text.length != 0)
                Container(
                    margin: EdgeInsets.only(top: 160, right: 40, left: 40),
                    height: 415.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        backgroundBlendMode: BlendMode.darken,
                        color: Colors.black.withOpacity(0.6))),
              if ((applicationBloc.searchNUSToResults != null ||
                      applicationBloc.searchToResults != null) &&
                  (applicationBloc.searchNUSToResults!.length != 0 ||
                      applicationBloc.searchToResults!.length != 0) &&
                  destinationAddressController.text.length != 0)
                Container(
                    padding: EdgeInsets.only(top: 160, right: 35, left: 35),
                    height: 415.0,
                    child: ListView.builder(
                        itemCount: (applicationBloc.searchToResults!.length +
                            applicationBloc.searchNUSToResults!.length),
                        itemBuilder: (context, index) {
                          if (index <
                              applicationBloc.searchNUSToResults!.length)
                            return ListTile(
                              title: Text(
                                applicationBloc.searchNUSToResults![index],
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _destinationAddress = nusVenuesData[
                                          applicationBloc
                                              .searchNUSToResults![index]]
                                      ["description"];
                                });

                                destinationAddressController.value =
                                    destinationAddressController.value.copyWith(
                                  text: applicationBloc
                                      .searchNUSToResults![index],
                                  selection: TextSelection.collapsed(
                                      offset: applicationBloc
                                          .searchNUSToResults![index].length),
                                );
                                _goToNUSPlace(
                                    nusVenuesData[applicationBloc
                                            .searchNUSToResults![index]]
                                        ["latitude"],
                                    nusVenuesData[applicationBloc
                                            .searchNUSToResults![index]]
                                        ["longitude"]);

                                applicationBloc.setNUSSelectedLocation();
                              },
                            );
                          else {
                            return ListTile(
                              title: Text(
                                applicationBloc
                                    .searchToResults![index -
                                        applicationBloc
                                            .searchNUSToResults!.length]
                                    .description,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _destinationAddress = applicationBloc
                                      .searchToResults![index -
                                          applicationBloc
                                              .searchNUSToResults!.length]
                                      .description;
                                });
                                _destinationAddress;
                                applicationBloc.setSelectedLocation(
                                    applicationBloc
                                        .searchToResults![index -
                                            applicationBloc
                                                .searchNUSToResults!.length]
                                        .placeId);
                                destinationAddressController.value =
                                    destinationAddressController.value.copyWith(
                                  text: applicationBloc
                                      .searchToResults![index -
                                          applicationBloc
                                              .searchNUSToResults!.length]
                                      .description,
                                  selection: TextSelection.collapsed(
                                      offset: applicationBloc
                                          .searchToResults![index -
                                              applicationBloc
                                                  .searchNUSToResults!.length]
                                          .description
                                          .length),
                                );
                              },
                            );
                          }
                        })),
              // Show current location button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    child: ClipOval(
                      child: Material(
                        color: Colors.blueGrey[100], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.my_location),
                          ),
                          onTap: () {
                            newMapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  zoom: 14.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToNUSPlace(double lat, double lng) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15)));

    _setMarkers(LatLng(lat, lng));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 15)));
    _setMarkers(
        LatLng(place.geometry.location.lat, place.geometry.location.lng));
  }
}
