import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchBox extends StatefulWidget {
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final searchLocationController = TextEditingController();
  final searchLocationFocusNode = FocusNode();
  String? _currentSearchLocation;
  String _finalSearchLocation = '';

  // can generalise / put in one file for both searchdirections
  // and searchbox usage
  Widget _textField({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? label,
    String? hint,
    double width = 1.0,
    Icon? prefixIcon,
    Widget? suffixIcon,
    Function(String)? locationEntered,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        // onChanged: (value) {
        //   locationEntered!(value);
        // },
        onChanged: (value) {
          findPlace(value);
          locationEntered!(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
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
          hintText: hint,
        ),
      ),
    );
  }

  void _getSearchQuery() async {
    try {
      setState(() {
        searchLocationController.text = _currentSearchLocation!;
        _finalSearchLocation = _currentSearchLocation!;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getSearchQuery();
  }

  @override
  Widget build(BuildContext context) {
    // Change to using Box like below with button leading to Google Places implementation
    var searchBoxWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 150.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 16.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6.0),
            Text(
              "Hey there, search information about a location in NUS below!",
              style: TextStyle(fontSize: 12.0),
            ),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    // Search Box
                    _textField(
                        controller: searchLocationController,
                        focusNode: searchLocationFocusNode,
                        prefixIcon:
                            Icon(Icons.search, color: Colors.blueAccent),
                        suffixIcon: Icon(Icons.edit, color: Colors.blueAccent),
                        width: searchBoxWidth,
                        hint: "Search",
                        // in charge of getting input
                        locationEntered: (String value) {
                          setState(() {
                            _finalSearchLocation = value;
                          });
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    setState(() {
      print(placeName);
    });
    print(placeName);
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M&sessiontoken=1234567890";
      var res = await http.get(Uri.https('maps.googleapis.com',
          'maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyCU-GY0MAZ-gFm38pWsaV0CRYpoo8eQ1-M&sessiontoken=1234567890'));
      // if (res == "failed") {
      //   return;
      // }
      print("Places Predictions Response :: ");
      print(res);
    }
  }
}
