// import 'dart:html';

import 'package:around_nus/blocs/application_bloc.dart';
import 'package:around_nus/models/place.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/drawer.dart';
import '../map_widgets/circularbutton.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';

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
  var _textController = TextEditingController(text: " ");
  Map nusVenuesData = {};
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
    this.loadJsonData();
    // this.getNames();
    super.initState();
    // get User Search; same as searchdirections
    // _setMarkers(LatLng(1.2966, 103.7764));

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

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/nusvenues.json');

    setState(() {
      nusVenuesData = json.decode(jsonText);
    });
    return "success";
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

  // void displayBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height * 0.4,
  //           child: Center(
  //             child: Text("Welcome to AndroidVille!"),
  //           ),
  //         );
  //       });
  // }

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
            padding: EdgeInsets.all(0),
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
                if (value != null) {
                  applicationBloc.searchNUSPlaces(value);
                  applicationBloc.searchPlaces(value);
                  applicationBloc.searchBusStops(value);
                }

                // getNUSAutoComplete(value);
              },
            ),
          ),
          Positioned(
              top: 640,
              left: 187,
              child: Align(
                // User Location Button
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  //onTap: _userLocationButton,
                  onTap: _userLocationButton,
                  child: CircularButton(),
                ),
              )),

          // darkened container background for the search results

          if ((applicationBloc.searchNUSResults != null ||
                  applicationBloc.searchResults != null ||
                  applicationBloc.searchBusStopsResults != null) &&
              (applicationBloc.searchNUSResults!.length != 0 ||
                  applicationBloc.searchResults!.length != 0 ||
                  applicationBloc.searchBusStopsResults != null) &&
              _textController.text.length != 0)
            Container(
                margin: EdgeInsets.only(top: 70),
                height: 415.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    color: Colors.black.withOpacity(0.6))),

          //container to store the search results
          if ((applicationBloc.searchNUSResults != null ||
                  applicationBloc.searchResults != null ||
                  applicationBloc.searchBusStopsResults != null) &&
              (applicationBloc.searchNUSResults!.length != 0 ||
                  applicationBloc.searchResults!.length != 0 ||
                  applicationBloc.searchBusStopsResults != null) &&
              _textController.text.length != 0)
            Container(
              padding: EdgeInsets.only(top: 70),
              height: 415.0,
              // child: _buildList()
              child: ListView.builder(
                // itemCount: applicationBloc.searchResults!.length,
                itemCount: (applicationBloc.searchNUSResults!.length +
                    applicationBloc.searchResults!.length +
                    applicationBloc.searchBusStopsResults!.length),
                itemBuilder: (context, index) {
                  print(index);
                  if (index < applicationBloc.searchNUSResults!.length)
                    return ListTile(
                      title: Text(
                        applicationBloc.searchNUSResults![index],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Text("Welcome to AndroidVille!"),
                                ),
                              );
                            });

                        _textController.value = _textController.value.copyWith(
                          text: applicationBloc.searchNUSResults![index],
                          selection: TextSelection.collapsed(
                              offset: applicationBloc
                                  .searchNUSResults![index].length),
                        );
                        _goToNUSPlace(
                            nusVenuesData[applicationBloc
                                .searchNUSResults![index]]["latitude"],
                            nusVenuesData[applicationBloc
                                .searchNUSResults![index]]["longitude"]);

                        applicationBloc.setNUSSelectedLocation();
                      },
                    );
                  else if (index <
                      applicationBloc.searchNUSResults!.length +
                          applicationBloc.searchResults!.length)
                    return ListTile(
                      title: Text(
                        applicationBloc
                            .searchResults![index -
                                applicationBloc.searchNUSResults!.length]
                            .description,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      child: Wrap(
                                        spacing: 8.0,
                                        children: [
                                          FilterChip(
                                              label: Text("Gym"),
                                              onSelected: (val) =>
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "gym", val),
                                              selected:
                                                  applicationBloc.placeType ==
                                                      "gym",
                                              selectedColor: Colors.blue),
                                          FilterChip(
                                              label: Text("ATM"),
                                              onSelected: (val) =>
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "atm", val),
                                              selected:
                                                  applicationBloc.placeType ==
                                                      "atm",
                                              selectedColor: Colors.blue)
                                        ],
                                      )));
                            });
                        applicationBloc.setSelectedLocation(applicationBloc
                            .searchResults![index -
                                applicationBloc.searchNUSResults!.length]
                            .placeId);
                        // //clearing the textfield
                        _textController.value = _textController.value.copyWith(
                          text: applicationBloc
                              .searchResults![index -
                                  applicationBloc.searchNUSResults!.length]
                              .description,
                          selection: TextSelection.collapsed(
                              offset: applicationBloc
                                  .searchResults![index -
                                      applicationBloc.searchNUSResults!.length]
                                  .description
                                  .length),
                        );
                      },
                    );
                  else {
                    return ListTile(
                      title: Text(
                        applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .longName +
                            " Bus Stop",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Text("Welcome to AndroidVille!"),
                                ),
                              );
                            });

                        _goToBusStop(
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .latitude,
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .longitude);

                        _textController.value = _textController.value.copyWith(
                          text: applicationBloc
                                  .searchBusStopsResults![index -
                                      applicationBloc.searchNUSResults!.length -
                                      applicationBloc.searchResults!.length]
                                  .longName +
                              " Bus Stop",
                          selection: TextSelection.collapsed(
                              offset: applicationBloc
                                      .searchBusStopsResults![index -
                                          applicationBloc
                                              .searchNUSResults!.length -
                                          applicationBloc.searchResults!.length]
                                      .longName
                                      .length +
                                  " Bus Stop".length),
                        );
                        applicationBloc.setBusStopSelectedLocation();
                      },
                    );
                  }
                },
              ),
            ),
          Positioned(
              top: 100,
              left: 100,
              child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Text("Welcome to AndroidVille!"),
                            ),
                          );
                        });
                  },
                  child: Icon(Icons.add))),
        ],
      ),
    );
  }

  Future<void> _goToNUSPlace(double lat, double lng) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15)));

    _setMarkers(LatLng(lat, lng));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry!.location.lat, place.geometry!.location.lng),
        zoom: 15)));

    _setMarkers(
        LatLng(place.geometry!.location.lat, place.geometry!.location.lng));
  }

  Future<void> _goToBusStop(double lat, double lng) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15)));

    _setMarkers(LatLng(lat, lng));
  }
}
