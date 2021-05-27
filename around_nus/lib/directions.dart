import 'package:flutter/material.dart';
import './fromsearchbar.dart';

class Directions extends StatefulWidget {
  Directions() {}
  @override
  State<StatefulWidget> createState() {
    return _DirectionsState();
  }
}

class _DirectionsState extends State<Directions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Directions"),
      ),
      body: Stack(
        alignment: const Alignment(10, 10),
        children: <Widget>[
          Positioned(
            top: 10,
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FromSearchBar()),
                );
              },
              child: Text("From"),
            ),
          ),
        ],
      ),
    );
  }
}
