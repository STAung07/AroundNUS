import 'package:flutter/material.dart';

class TurnOnLocation extends StatelessWidget {
  final String _userText;

  TurnOnLocation(this._userText);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Location Services ' + _userText),
        content: Text(
            'Turn on Location Services or give Location Permission for better experience'));
  }
}
