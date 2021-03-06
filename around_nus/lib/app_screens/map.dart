// import 'dart:html';

import 'package:around_nus/blocs/application_bloc.dart';
import 'package:around_nus/models/place.dart';
import 'package:around_nus/services/places_service.dart';

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
  late StreamSubscription boundsSubscription;
  var _textController = TextEditingController(text: "");
  Map nusVenuesData = {};
  String displayName = "";
  String displayPhoneNumber = "";
  String displayFullAddress = "";

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        if (place.name != null) displayName = place.name!;
        if (place.phoneNumber != null) displayPhoneNumber = place.phoneNumber!;
        if (place.address != null) displayFullAddress = place.address!;

        _goToPlace(place);
      }
    });
    this.loadJsonData();

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _controllerGoogleMap.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    });

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
    boundsSubscription.cancel();
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void locatePosition() async {
    //Position position = await _determinePosition();
    ///*
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //    */
    currentPosition = position;
    currCoordinates = LatLng(position.latitude, position.longitude);

    //if latlng position out of range of NUS, set latlng position to _defaultCameraPos
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 16);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Set<Marker> _markers = <Marker>{};
  Set<Marker> _markers2 = <Marker>{};
  Marker mainMarker = Marker(
    markerId: MarkerId("start"),
    position: LatLng(0, 0),
    infoWindow: InfoWindow(title: "Start", snippet: "test"),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  );
  bool _isMarker = false;

  void _setMarkers(LatLng point, String name) {
    _isMarker = true;
    // final applicationBloc = Provider.of<ApplicationBloc>(context);
    setState(() {
      _markers2.clear();
      // applicationBloc.clearMarkers();

      // Pass to search info widget
      // add markers subsequently on taps
      mainMarker = Marker(
        markerId: MarkerId("$point"),
        position: point,
        infoWindow: InfoWindow(title: name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
  }

  // function to call when user presses userLocation button
  void _userLocationButton() {
    locatePosition();
    _setMarkers(currCoordinates, "Current Location");
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    CameraPosition _initialCameraPosition;
    int phoneHeight = MediaQuery.of(context).size.height.round();
    int phoneWidth = MediaQuery.of(context).size.width.round();

    if (applicationBloc.currentLocation == null) {
      _initialCameraPosition =
          CameraPosition(target: LatLng(1.2966, 103.7764), zoom: 16);
    } else {
      _initialCameraPosition = CameraPosition(
          target: LatLng(applicationBloc.currentLocation!.latitude,
              applicationBloc.currentLocation!.longitude),
          zoom: 16);
    }
    _markers2.clear();
    _markers2.add(mainMarker);
    _markers2.addAll(applicationBloc.markers);
    // applicationBloc.clearMarkers();

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
              // _setMarkers(currCoordinates);
            },
            // enable location layer
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            // markers
            markers: _markers2,
            // markers: Set<Marker>.of(applicationBloc.markers),
            // onTap: (point) {
            //   if (_isMarker) {
            //     setState(() {
            //       // _markers.clear();
            //       _setMarkers(point);
            //     });
            //   }
            // },
            // camera target bounds ? to limit to NUS
          ),
          Container(
              height: 55,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0)),
                  color: Colors.white)),
          Container(
            padding: EdgeInsets.all(0),
            child: TextField(
              onTap: () {
                print("tapped on text field");
                applicationBloc.searchNUSPlaces(_textController.text);
                applicationBloc.searchPlaces(_textController.text);
                applicationBloc.searchBusStops(_textController.text);
              },
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
              // top: 640,
              top: phoneHeight * 0.8,
              left: phoneWidth * 0.5 - 20,
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

          if ((applicationBloc.searchNUSResults != null &&
                  applicationBloc.searchResults != null &&
                  applicationBloc.searchBusStopsResults != null) &&
              (applicationBloc.searchNUSResults!.length != 0 ||
                  applicationBloc.searchResults!.length != 0 ||
                  applicationBloc.searchBusStopsResults!.length != 0) &&
              _textController.text.length != 0)
            Container(
                margin: EdgeInsets.only(top: 50),
                height: 365.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    color: Colors.black.withOpacity(0.6))),

          //container to store the search results
          if ((applicationBloc.searchNUSResults != null &&
                  applicationBloc.searchResults != null &&
                  applicationBloc.searchBusStopsResults != null) &&
              (applicationBloc.searchNUSResults!.length != 0 ||
                  applicationBloc.searchResults!.length != 0 ||
                  applicationBloc.searchBusStopsResults!.length != 0) &&
              _textController.text.length != 0)
            Container(
              padding: EdgeInsets.only(top: 50),
              height: 415.0,
              // child: _buildList()
              child: ListView.builder(
                // itemCount: applicationBloc.searchResults!.length,
                itemCount: (applicationBloc.searchNUSResults!.length +
                    applicationBloc.searchResults!.length +
                    applicationBloc.searchBusStopsResults!.length),
                itemBuilder: (context, index) {
                  if (index < applicationBloc.searchResults!.length)
                    return ListTile(
                      title: Text(
                        applicationBloc.searchResults![index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        applicationBloc.clearMarkers();

                        //not using these for now
                        // String mainPlaceName =
                        //     applicationBloc.searchResults![index].name;
                        // String mainPlaceLongName =
                        //     applicationBloc.searchResults![index].description;

                        FocusScope.of(context).unfocus();

                        applicationBloc.setSelectedLocation(
                            applicationBloc.searchResults![index].placeId);

                        _textController.value = _textController.value.copyWith(
                          text:
                              applicationBloc.searchResults![index].description,
                          selection: TextSelection.collapsed(
                              offset: applicationBloc
                                  .searchResults![index].description.length),
                        );

                        //retrieving extra info on the selected location
                        var selectedLocation = await PlacesService().getPlace(
                            applicationBloc.searchResults![index].placeId);

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ListView(
                                children: [
                                  Stack(children: [
                                    Container(
                                      width: 425,
                                      height: 50,
                                      color: Colors.blueGrey[500],
                                      child: Text(selectedLocation.name!,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                      alignment: Alignment.center,
                                    ),
                                  ]),

                                  // PICTURES
                                  // first pic at the top
                                  if (selectedLocation.photoReference != null)
                                    Padding(
                                        padding: const EdgeInsets.all(1.5),
                                        child: Image.network(
                                            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=${phoneWidth - 10}&photoreference=${selectedLocation.photoReference![0]}&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M')),

                                  //second pic at the bottom left
                                  if (selectedLocation.photoReference != null &&
                                      selectedLocation.photoReference!.length >=
                                          3)
                                    Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Image.network(
                                                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=${(phoneWidth * 0.5 - 10).round()}&maxheight=${(phoneHeight * 0.25).round()}&photoreference=${selectedLocation.photoReference![1]}&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M'),
                                              Image.network(
                                                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=${(phoneWidth * 0.5 - 10).round()}&maxheight=${(phoneHeight * 0.25).round()}&photoreference=${selectedLocation.photoReference![2]}&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M')
                                            ])),

                                  // ELABORATED ADDRESS
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Icon(Icons.location_pin),
                                        Container(
                                            width: 350,
                                            child: Text(
                                                selectedLocation.address!)),
                                      ])),

                                  //FORMATTED PHONE NUMBER
                                  if (selectedLocation.phoneNumber != null)
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          Icon(Icons.phone),
                                          Container(
                                              width: 350,
                                              child: Text(selectedLocation
                                                  .phoneNumber!)),
                                        ])),

                                  // OPEN
                                  if (selectedLocation.isOpen != null &&
                                      selectedLocation.isOpen == true)
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          Icon(Icons.alarm),
                                          Container(
                                              width: 350,
                                              child: Text("Open",
                                                  style: TextStyle(
                                                      color: Colors.green))),
                                        ])),

                                  // CLOSED
                                  if (selectedLocation.isOpen != null &&
                                      selectedLocation.isOpen == false)
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          Icon(Icons.alarm),
                                          Container(
                                              width: 350,
                                              child: Text("Closed",
                                                  style: TextStyle(
                                                      color: Colors.red))),
                                        ])),

                                  // OPENING HOURS FOR THE WEEK
                                  for (int i = 0; i < 7; i++)
                                    if (selectedLocation.isOpen != null &&
                                        selectedLocation.openingHours != null)
                                      Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Row(children: [
                                            Icon(Icons.arrow_right),
                                            Container(
                                                width: 350,
                                                child: Text(
                                                  selectedLocation
                                                      .openingHours![i],
                                                )),
                                          ])),

                                  // FIND NEAREST AMENITIES
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Find Nearest",
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: Wrap(
                                            spacing: 8.0,
                                            children: [
                                              FilterChip(
                                                  label: Text("Gym"),
                                                  onSelected: (val) {
                                                    applicationBloc
                                                        .togglePlaceType(
                                                            "gym", val);
                                                    _markers.addAll(
                                                        applicationBloc
                                                            .markers);
                                                    Navigator.pop(context);
                                                  }),
                                              FilterChip(
                                                label: Text("ATM"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "atm", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                                // selected: applicationBloc
                                                //         .placeType ==
                                                //     "atm",
                                                // selectedColor:
                                                //     Colors.blueGrey
                                              ),
                                              FilterChip(
                                                label: Text("Cafe"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "cafe", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Car Park"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "parking", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Restaurant"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "restaurant", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label:
                                                    Text("Convenience Store"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "convenience_store",
                                                          val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Post Office"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "post_office", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          ))),
                                ],
                              );
                            });
                        // applicationBloc.setSelectedLocation(
                        //     applicationBloc.searchResults![index].placeId);
                        // //clearing the textfield
                      },
                    );
                  else if (index <
                      applicationBloc.searchNUSResults!.length +
                          applicationBloc.searchResults!.length)
                    return ListTile(
                      title: Text(
                        applicationBloc.searchNUSResults![
                            index - applicationBloc.searchResults!.length],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        applicationBloc.clearMarkers();
                        String mainPlaceName =
                            applicationBloc.searchNUSResults![
                                index - applicationBloc.searchResults!.length];
                        String longMainPlaceName = nusVenuesData[applicationBloc
                                    .searchNUSResults![
                                index - applicationBloc.searchResults!.length]]
                            ["description"];
                        FocusScope.of(context).unfocus();

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              print("inside NUS results");
                              print(mainPlaceName);
                              return ListView(
                                children: [
                                  Stack(children: [
                                    Container(
                                      width: 425,
                                      height: 50,
                                      color: Colors.blueGrey[500],
                                      child: Text(mainPlaceName,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                      alignment: Alignment.center,
                                    ),
                                  ]),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Icon(Icons.location_pin),
                                        Container(
                                            width: 350,
                                            child: Text(longMainPlaceName)),
                                      ])),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Find Nearest",
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: Wrap(
                                            spacing: 8.0,
                                            children: [
                                              FilterChip(
                                                label: Text("Gym"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "gym", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("ATM"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "atm", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Cafe"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "cafe", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Car Park"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "parking", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Restaurant"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "restaurant", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label:
                                                    Text("Convenience Store"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "convenience_store",
                                                          val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Post Office"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "post_office", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          ))),
                                ],
                              );
                            });

                        _textController.value = _textController.value.copyWith(
                          text: applicationBloc.searchNUSResults![
                              index - applicationBloc.searchResults!.length],
                          selection: TextSelection.collapsed(
                              offset: applicationBloc
                                  .searchNUSResults![index -
                                      applicationBloc.searchResults!.length]
                                  .length),
                        );
                        _goToNUSPlace(
                            nusVenuesData[applicationBloc.searchNUSResults![
                                    index - applicationBloc.searchResults!.length]]
                                ["latitude"],
                            nusVenuesData[applicationBloc.searchNUSResults![
                                    index -
                                        applicationBloc.searchResults!.length]]
                                ["longitude"],
                            nusVenuesData[applicationBloc.searchNUSResults![
                                    index -
                                        applicationBloc.searchResults!.length]]
                                ["name"]);

                        applicationBloc.setNUSSelectedLocation(
                            nusVenuesData[applicationBloc.searchNUSResults![
                                    index -
                                        applicationBloc.searchResults!.length]]
                                ["latitude"],
                            nusVenuesData[applicationBloc.searchNUSResults![
                                    index -
                                        applicationBloc.searchResults!.length]]
                                ["longitude"],
                            applicationBloc.searchNUSResults![
                                index - applicationBloc.searchResults!.length]);
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
                        applicationBloc.clearMarkers();
                        String mainPlaceName = applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .shortName +
                            " Bus Stop";
                        FocusScope.of(context).unfocus();

                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              print("inside Bus Stops results");
                              print(mainPlaceName);
                              return ListView(
                                children: [
                                  Stack(children: [
                                    Container(
                                      width: 425,
                                      height: 50,
                                      color: Colors.blueGrey[500],
                                      child: Text(mainPlaceName,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                      alignment: Alignment.center,
                                    ),
                                  ]),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Find Nearest",
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: Wrap(
                                            spacing: 8.0,
                                            children: [
                                              FilterChip(
                                                label: Text("Gym"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "gym", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("ATM"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "atm", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Cafe"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "cafe", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Car Park"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "parking", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Restaurant"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "restaurant", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label:
                                                    Text("Convenience Store"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "convenience_store",
                                                          val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FilterChip(
                                                label: Text("Post Office"),
                                                onSelected: (val) {
                                                  applicationBloc
                                                      .togglePlaceType(
                                                          "post_office", val);
                                                  _markers.addAll(
                                                      applicationBloc.markers);
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          ))),
                                ],
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
                                .longitude,
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .name);

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
                        applicationBloc.setBusStopSelectedLocation(
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .latitude,
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .longitude,
                            applicationBloc
                                .searchBusStopsResults![index -
                                    applicationBloc.searchNUSResults!.length -
                                    applicationBloc.searchResults!.length]
                                .longName);
                      },
                    );
                  }
                },
              ),
            ),
          // Positioned(
          //     top: 100,
          //     left: 100,
          //     child: FloatingActionButton(
          //         onPressed: () {
          //           showModalBottomSheet(
          //               context: context,
          //               builder: (context) {
          //                 return Container(
          //                   height: MediaQuery.of(context).size.height * 0.4,
          //                   child: Center(
          //                     child: Text("Welcome to AndroidVille!"),
          //                   ),
          //                 );
          //               });
          //         },
          //         child: Icon(Icons.add))),
        ],
      ),
    );
  }

  Future<void> _goToNUSPlace(double lat, double lng, String name) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat - 0.00075, lng), zoom: 18)));

    _setMarkers(LatLng(lat, lng), name);
  }

  Future<void> _goToPlace(Place place) async {
    print("in go to place");
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(place.geometry!.location.lat - 0.00075,
            place.geometry!.location.lng),
        zoom: 18)));

    _setMarkers(
        LatLng(place.geometry!.location.lat, place.geometry!.location.lng),
        place.name!);
  }

  Future<void> _goToBusStop(double lat, double lng, String name) async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat - 0.00075, lng), zoom: 18)));

    _setMarkers(LatLng(lat, lng), name + " Bus Stop");
  }
}
