import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245.0,
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
          children: [
            SizedBox(height: 6.0),
            Text(
              "Hey there, search information about a location in NUS below!",
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
