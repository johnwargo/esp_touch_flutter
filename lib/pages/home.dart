// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'dart:core';
//import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity/connectivity.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:passwordfield/passwordfield.dart';

class EspTouchHome extends StatefulWidget {
  EspTouchHome({Key key, this.appName}) : super(key: key);

  final String appName;

  @override
  _EspTouchHomeState createState() => _EspTouchHomeState();
}

class _EspTouchHomeState extends State<EspTouchHome> {

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TextEditingController connectionStatusController;
  TextEditingController wifiPasswordController;

  String _connectionStatus = 'Unknown';
  String _remoteNotifyIPAddress;
  String _remoteNotifyMacAddress;
  String _wifiBSSID;
  String _wifiName;
  String _wifiPassword;

  @override
  void initState() {
    print('initState()');
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    connectionStatusController = TextEditingController(text: _connectionStatus);
    wifiPasswordController = TextEditingController(text: _wifiPassword);
  }

  @override
  void dispose() {
    print('dispose()');
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
          Text("Connection Status: $_connectionStatus"),
          Text("Network Name (SSID): $_wifiName"),
          Text("Base Station ID (BSID): $_wifiBSSID"),
          SizedBox(height: 10),
          Text("Wi-Fi Network Password"),
          SizedBox(height: 10),
          PasswordField(
            color: Colors.black,
            hasFloatingPlaceholder: true,
            controller: wifiPasswordController,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(width: 2, color: Colors.black)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 2, color: Colors.blueAccent)),
          ),
          SizedBox(height: 10),
          Text(
              "Tap the Push Configuration button to save the Wi-Fi configuration to your Remote Notify device. Make sure the device is powered on before tapping the button."),
          SizedBox(height: 10),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: setWifiConfig,
            child: Text(
              "Push Configuration",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 10),
          Text("Remote Notify"),
          Text("IP Address: $_remoteNotifyIPAddress"),
          Text("Mac Address: $_remoteNotifyMacAddress"),
        ]),
      ),
    );
  }

  void setWifiConfig() {
    // TODO: validate the config first
    print('setWifiConfig');
    final ESPTouchTask task = ESPTouchTask(
      ssid: _wifiName,
      bssid: _wifiBSSID,
      password: _wifiPassword,
    );
    final Stream<ESPTouchResult> stream = task.execute();
    final printResult = (ESPTouchResult result) {
      print('IP: ${result.ip} MAC: ${result.bssid}');
      setState(() {
        _remoteNotifyIPAddress = result.ip;
        _remoteNotifyMacAddress = result.bssid;
      });
    };
    StreamSubscription<ESPTouchResult> streamSubscription =
        stream.listen(printResult);
    // Don't forget to cancel your stream subscription:
    streamSubscription.cancel();
  }

  Future<void> initConnectivity() async {
    print('initConnectivity()');
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

    // Check to see if Android Location permissions are enabled
    // Described in https://github.com/flutter/flutter/issues/51529
    if (Platform.isAndroid) {
      print('Checking Android permissions');
      var status = await Permission.location.status;
      // Blocked?
      if (status.isUndetermined || status.isDenied || status.isRestricted) {
        // Ask the user to unblock
        if (await Permission.location.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Location permission granted');
        } else {
          print('Location permission not granted');
        }
      } else {
        print('Permission already granted (previous execution?)');
      }
    }

    return _updateConnectionStatus(result);
  }

//  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
//    print('_updateConnectionStatus($result)');
//    switch (result) {
//      case ConnectivityResult.wifi:
//        print('_updateConnectionStatus: Wi-Fi');
//        String wifiName, wifiBSSID;
//
//        try {
//          if (Platform.isIOS) {
//            LocationAuthorizationStatus status =
//                await _connectivity.getLocationServiceAuthorization();
//            if (status == LocationAuthorizationStatus.notDetermined) {
//              status =
//                  await _connectivity.requestLocationServiceAuthorization();
//            }
//            if (status == LocationAuthorizationStatus.authorizedAlways ||
//                status == LocationAuthorizationStatus.authorizedWhenInUse) {
//              wifiName = await _connectivity.getWifiName();
//            } else {
//              wifiName = await _connectivity.getWifiName();
//            }
//          } else {
//            wifiName = await _connectivity.getWifiName();
//          }
//        } on PlatformException catch (e) {
//          print(e.toString());
//          wifiName = "Failed to get Wi-Fi Name";
//        }
//        print('Wi-Fi Name: $wifiName');
//
//        try {
//          if (Platform.isIOS) {
//            LocationAuthorizationStatus status =
//                await _connectivity.getLocationServiceAuthorization();
//            if (status == LocationAuthorizationStatus.notDetermined) {
//              status =
//                  await _connectivity.requestLocationServiceAuthorization();
//            }
//            if (status == LocationAuthorizationStatus.authorizedAlways ||
//                status == LocationAuthorizationStatus.authorizedWhenInUse) {
//              wifiBSSID = await _connectivity.getWifiBSSID();
//            } else {
//              wifiBSSID = await _connectivity.getWifiBSSID();
//            }
//          } else {
//            wifiBSSID = await _connectivity.getWifiBSSID();
//          }
//        } on PlatformException catch (e) {
//          print(e.toString());
//          wifiBSSID = "Failed to get Wi-Fi BSSID";
//        }
//        print('BSSID: $wifiBSSID');
//
//        setState(() {
//          _wifiName = wifiName;
//          _wifiBSSID = wifiBSSID;
//        });
//        break;
//      case ConnectivityResult.mobile:
//        print('_updateConnectionStatus: mobile');
//        setState(() => _connectionStatus = result.toString());
//        break;
//      case ConnectivityResult.none:
//      print('_updateConnectionStatus: none');
//        setState(() => _connectionStatus = result.toString());
//        break;
//      default:
//        print('_updateConnectionStatus: default');
//        setState(() => _connectionStatus = 'Failed to get connectivity.');
//        break;
//    }
//  }

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
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() => _wifiName = wifiName);
        setState(() => _wifiBSSID = wifiBSSID);
//        setState(() => _wifiIP = wifiIP);
//        setState(() => _wifiList = wList);

//        setState(() {
//          _wifiName = wifiName;
//        });
//          setState(() {
//          _wifiBSSID = wifiBSSID;
//        });

//        setState(() {
//          _connectionStatus = '$result\n'
//              'Wifi Name: $wifiName\n'
//              'Wifi BSSID: $wifiBSSID\n'
////              'Wifi IP: $wifiIP\n';
//        });
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
}
