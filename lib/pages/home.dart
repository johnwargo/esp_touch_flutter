import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class EspTouchHome extends StatefulWidget {
  EspTouchHome({Key key, this.appName}) : super(key: key);

  final String appName;

  @override
  _EspTouchHomeState createState() => _EspTouchHomeState();
}

class _EspTouchHomeState extends State<EspTouchHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
      ),
      body: SafeArea(
        child: Text('This is a test')
      ),
    );
  }

}

getNetworkInfo(){
  var wifiBSSID = await (Connectivity().getWifiBSSID());
  var wifiIP = await (Connectivity().getWifiIP());network
  var wifiName = await (Connectivity().getWifiName());wifi network
}
