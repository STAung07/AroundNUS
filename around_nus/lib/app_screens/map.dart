import 'package:around_nus/blocs/application_bloc.dart';
import 'package:around_nus/models/place.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../common_widgets/drawer.dart';
import '../map_widgets/circularbutton.dart';
import 'dart:convert' as convert;
import 'package:dio/dio.dart';

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
  late StreamSubscription locationSubscription;
  var _textController = TextEditingController();
  // List filteredNames = [];
  // List names = [];

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
    // this.getNames();
    super.initState();
    // get User Search; same as searchdirections
    _setMarkers(LatLng(1.2966, 103.7764));
    locatePosition();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    locationSubscription.cancel();
    _textController.dispose();
    super.dispose();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    currCoordinates = LatLng(position.latitude, position.longitude);

    //if latlng position out of range of NUS, set latlng position to _defaultCameraPos
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 15);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Set<Marker> _markers = <Marker>{};
  bool _isMarker = false;

  // set marker for one other location
  void _setMarkers(LatLng point) {
    _isMarker = true;
    setState(() {
      _markers.clear();
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
    locatePosition();
    _setMarkers(currCoordinates);
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    CameraPosition _initialCameraPosition;
    // int searchCount = 0;

    if (applicationBloc.currentLocation == null) {
      _initialCameraPosition =
          CameraPosition(target: LatLng(1.2966, 103.7764), zoom: 15);
    } else {
      _initialCameraPosition = CameraPosition(
          target: LatLng(applicationBloc.currentLocation!.latitude,
              applicationBloc.currentLocation!.longitude),
          zoom: 15);
    }

    // Widget _buildList() {
    //   List tempList = [];
    //   for (int i = 0; i < filteredNames.length; i++) {
    //     if (filteredNames[i]
    //         .toLowerCase()
    //         .contains(_textController.text.toLowerCase())) {
    //       tempList.add(filteredNames[i]);
    //       print(_textController.text);
    //     }
    //   }

    //   filteredNames = tempList;

    //   return ListView.builder(
    //     itemCount: filteredNames.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return ListTile(title: Text(filteredNames[index]));
    //     },
    //   );
    // }

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
            //initialCameraPosition: _defaultCameraPos,
            initialCameraPosition: _initialCameraPosition,
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
                  // _markers.clear();
                  _setMarkers(point);
                });
              }
            },
            // camera target bounds ? to limit to NUS
          ),
          Container(
              height: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0)),
                  color: Colors.white)),
          Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                  hintText: "Search Location ...",
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.clear();
                        });
                      }),
                  prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                applicationBloc.searchNUSPlaces(value);
                // getNUSAutoComplete(value);
              },
            ),
          ),
          Align(
            // User Location Button
            alignment: Alignment.bottomCenter,
            child: InkWell(
              //onTap: _userLocationButton,
              onTap: _userLocationButton,
              child: CircularButton(),
            ),
          ),

          // darkened container background for the search results

          if (applicationBloc.searchNUSResults != null &&
              applicationBloc.searchNUSResults!.length != 0 &&
              _textController.text.length != 0)
            Container(
                margin: EdgeInsets.only(top: 70),
                height: 415.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    color: Colors.black.withOpacity(0.6))),

          //container to store the search results
          if (applicationBloc.searchNUSResults != null &&
              applicationBloc.searchNUSResults!.length != 0 &&
              _textController.text.length != 0)
            Container(
                padding: EdgeInsets.only(top: 70),
                height: 300.0,
                // child: _buildList()
                child: ListView.builder(
                    // itemCount: applicationBloc.searchResults!.length,
                    itemCount: applicationBloc.searchNUSResults!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          applicationBloc.searchNUSResults![index],
                          style: TextStyle(color: Colors.white),
                        ),
                        // onTap: () {
                        //   applicationBloc.setSelectedLocation(
                        //       applicationBloc.searchResults![index].placeId);
                        //   _textController.value =
                        //       _textController.value.copyWith(
                        //     text: applicationBloc
                        //         .searchResults![index].description,
                        //     selection: TextSelection.collapsed(
                        //         offset: applicationBloc
                        //             .searchResults![index].description.length),
                        //   );
                        // },
                      );
                    }))
        ],
      ),
    );
  }

  // Future<List> getNUSAutoComplete() async {
  //   var url = "https://api.nusmods.com/v2/2020-2021/semesters/2/venues.json";
  //   var results = [];
  //   var response = await http.get(Uri.parse(url));
  //   var venues = convert.jsonDecode(response.body);
  //   for (int i = 0; i < venues.length; i++) {
  //     if (venues[i].toLowerCase().contains(search.toLowerCase())) {
  //       print(venues[i]);
  //       results.add(venues[i]);
  //     }
  //   }
  //   return results;
  // }
  // void getNames() async {
  //   var url = "https://api.nusmods.com/v2/2020-2021/semesters/2/venues.json";
  //   var tempList = [];
  //   // var response = await http.get(Uri.parse(url));
  //   // var venues = convert.jsonDecode(response.body);
  //   final response = await Dio().get(url);
  //   for (int i = 0; i < response.data.length; i++) {
  //     tempList.add(response.data[i]);
  //   }

  //   setState(() {
  //     names = tempList;
  //     names.shuffle();
  //     filteredNames = names;
  //   });
  // }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 15)));

    _setMarkers(
        LatLng(place.geometry.location.lat, place.geometry.location.lng));
  }
}
