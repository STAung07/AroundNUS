import 'package:flutter/material.dart';

class FromSearch extends StatefulWidget {
  FromSearch() {}
  @override
  State<StatefulWidget> createState() {
    return _FromSearchState();
  }
}

class _FromSearchState extends State<FromSearch> {
  @override
  void initState() {
    filteredList = fooList;
    super.initState();
  }

  List fooList = ['one', 'two', 'three', 'four', 'five'];
  List filteredList = [];

  void filter(String inputString) {
    filteredList =
        fooList.where((i) => i.toLowerCase().contains(inputString)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search ',
              hintStyle: TextStyle(
                fontSize: 14,
              ),
            ),
            onChanged: (text) {
              text = text.toLowerCase();
              filter(text);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(filteredList[index]),
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Display(
                //         text: filteredList[index],
                //       ),
                //     ),
                //   );
                // },
              ),
            ),
          )
        ],
      ),
    );
  }
}
