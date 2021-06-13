import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../common_widgets/drawer.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7285A5),
        title: Text("Settings"),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'General',
            tiles: [
              SettingsTile(
                title: 'Language',
                leading: Icon(Icons.language),
              ),
            ],
          ),
        ],
      ),
      /*
      Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back"),
        ),
      ),
      */
    );
  }
}
