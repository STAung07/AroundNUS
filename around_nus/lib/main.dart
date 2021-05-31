import 'package:around_nus/blocs/application_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './app_screens/map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: MaterialApp(
        title: 'AroundNUS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: MyMainPage(title: 'AroundNUS'),
      ),
    );
  }
}
