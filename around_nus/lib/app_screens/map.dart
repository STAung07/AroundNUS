import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../common_widgets/drawer.dart';
import '../map_widgets/circularbutton.dart';
import '../map_widgets/searchbox.dart';
import '../map_widgets/turnonlocation.dart';

class MyMainPage extends StatefulWidget {
  MyMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  late Position currentPosition;
  late LatLng currCoordinates =
      LatLng(currentPosition.latitude, currentPosition.longitude);
  var geoLocator = Geolocator();

  void locatePosition() async {
    // bool serviceEnabled;
    // LocationPermission permission;

    // // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Dialog box asking user to turn on Location Services
    //   showDialog(context: context, builder: (_) => TurnOnLocation('Disabled'));
    //   return;
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     showDialog(context: context, builder: (_) => TurnOnLocation('Denied'));
    //     return;
    //   }
    // }
    // if (permission == LocationPermission.deniedForever) {
    //   showDialog(
    //       context: context,
    //       builder: (_) => TurnOnLocation('Permanently Denied'));
    //   return;
    // }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    // if latlng position out of range of NUS, set latlng position to _defaultCameraPos
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14.4746);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static final CameraPosition _defaultCameraPos = CameraPosition(
    target: LatLng(1.2966, 103.7764),
    zoom: 14.4746,
  );

  Set<Marker> _markers = <Marker>{};

  bool _isMarker = false;

  // set marker for one other location
  void _setMarkers(LatLng point) {
    _isMarker = true;
    setState(() {
      // Pass to search info widget
      // add markers subsequently on taps
      _markers.add(
        Marker(
          markerId: MarkerId('Location'),
          position: point,
        ),
      );
    });
  }

  // function to call when user presses userLocation button
  void _userLocationButton() {
    _setMarkers(currCoordinates);
    locatePosition();
  }

  @override
  void initState() {
    super.initState();
    // get User Search; same as searchdirections
    // void initState()
    _setMarkers(LatLng(1.2966, 103.7764));
    locatePosition();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            // disable location button; make own button
            myLocationButtonEnabled: false,
            initialCameraPosition: _defaultCameraPos,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              // after position located, then setMarker
              //locatePosition();
              _setMarkers(currCoordinates);
            },
            // enable location layer
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            // markers
            markers: _markers,
            onTap: (point) {
              if (_isMarker) {
                setState(() {
                  _markers.clear();
                  _setMarkers(point);
                });
              }
            },
            // camera target bounds ? to limit to NUS
          ),
          Positioned(
            top: 0.0,
            left: 0.5,
            right: 0.5,
            child: SearchBox(),
          ),
          Align(
            // User Location Button
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: _userLocationButton,
              child: CircularButton(),
            ),
          )
        ],
      ),
    );
  }
}
