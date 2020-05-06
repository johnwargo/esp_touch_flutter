import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EspTouchHome extends StatefulWidget {
  EspTouchHome({Key key, this.appName}) : super(key: key);

  final String appName;

  @override
  _EspTouchHomeState createState() => _EspTouchHomeState();
}

class _EspTouchHomeState extends State<EspTouchHome> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

//  String _networkStatus;
  String _wifiBSSID;
  String _wifiIP;
  String _wifiName;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//    WidgetsBinding.instance.addPostFrameCallback((_) => getNetworkInfo());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16.0), children: <Widget>[
//          Text("Status: $_networkStatus"),
//          Text("Wi-Fi Base Station ID (BSID): $_wifiBSSID"),
//          Text("IP Address: $_wifiIP"),
          Text("Connection:  $_connectionStatus"),
        ]),
      ),
    );
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              _wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              _wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            _wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          _wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          _wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          _wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $_wifiName\n'
              'Wifi BSSID: $_wifiBSSID\n'
              'Wifi IP: $_wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

//  void getNetworkInfo() async {
//    var statusString = 'Unknown';
//    var connectivityResult = await (Connectivity().checkConnectivity());
//    if (connectivityResult == ConnectivityResult.mobile) {
//      statusString = 'Mobile';
//    } else if (connectivityResult == ConnectivityResult.wifi) {
//      statusString = 'Wi-Fi';
//      String var1 = await (Connectivity().getWifiBSSID());
//      setState(() => _wifiBSSID = var1);
//      String var2 = await (Connectivity().getWifiIP());
//      setState(() => _wifiIP = var2);
//      String var3 = await (Connectivity().getWifiName());
//      setState(() => _wifiName = var3);
//    }
//    setState(() => _networkStatus = statusString);
//  }
}
