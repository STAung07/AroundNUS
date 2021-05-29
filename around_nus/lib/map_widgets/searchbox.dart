import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  //final TextEditingController locationController;

  SearchBox(/*locationController*/);
  /*
  Widget _textField({
    TextEditingController? controller,
    String? label,
    String? hint,
    Icon? prefixIcon,
    double width = 1.0,
    Function(String)? locationEntered,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationEntered!(value);
        },
        controller: controller,
        decoration: new InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
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
  */

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          hintText: "Search",
          labelText:
              "Hey there, search information about a location in NUS below!"),
    );
    // Change to using Box like below with button leading to Google Places implementation

    /*
    Container(
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
                    Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Search"),
                    ),
                    /*
                    _textField(
                      controller: locationController,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      hint: "Search",
                    ),
                    */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    */
  }
}
