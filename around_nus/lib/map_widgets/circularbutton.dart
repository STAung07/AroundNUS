import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  CircularButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), color: Colors.blue),
      child: Icon(Icons.my_location, color: Colors.white),
    );
  }
}
