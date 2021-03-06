import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:permission_handler/permission_handler.dart';

import '../classes/config.dart';

final Config config = new Config();

class EspTouchHome extends StatefulWidget {
  EspTouchHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EspTouchHomeState createState() => _EspTouchHomeState();
}

class _EspTouchHomeState extends State<EspTouchHome> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  StreamSubscription<ESPTouchResult> _streamSubscription;

  Timer _timer;

  TextEditingController wifiPasswordController;

  String _connectionStatus = 'Unknown';
  String _remoteNotifyIPAddress;
  String _remoteNotifyMacAddress;
  String _wifiBSSID;
  String _wifiName;
  String _wifiPassword;
  bool _saveWifiPassword;

  // used to control the enabled status of the Push Configuration and Cancel
  // buttons one is always disabled while the other is enabled
  bool buttonStatus = true;

  @override
  void initState() {
    print('initState()');
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<bool> loadConfigAsync() async {
    // Note, this runs multiple times on startup because initConnectivity
    // sets state which causes the Builder to run again. This isn't a problem,
    // just a bit goofy
    print('Home: loadConfigAsync()');
    // Initialize the config object
    await config.loadData();
    // We saving the password?
    _saveWifiPassword = config.saveWiFiPassword;
    // initialize the Wi-Fi password (if we're saving it)
    _saveWifiPassword
        ? _wifiPassword = config.wifiPassword
        : _wifiPassword = '';
    wifiPasswordController = TextEditingController(text: _wifiPassword);
    wifiPasswordController.addListener(() {
      _wifiPassword = wifiPasswordController.text;
    });
    // Tell FutureBuilder we're ready to go...
    return true;
  }

  @override
  void dispose() {
    print('dispose()');
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void updateCheckValue(bool value) {
    print('Home: updateCheckValue($value)');
    // Write the setting to the config
    config.saveWiFiPassword = value;
    // Then update the internal value
    setState(() => _saveWifiPassword = value);
  }

  void setWifiConfig() {
    print('setWifiConfig()');
    if (_wifiName != null && _wifiBSSID != null && _wifiPassword != null) {
      print('Setting Wi-Fi config');
      setState(() {
        buttonStatus = !buttonStatus;
        _wifiPassword = wifiPasswordController.text;
      });
      _saveWifiPassword
          ? config.wifiPassword = _wifiPassword
          : config.wifiPassword = '';
      final ESPTouchTask task = ESPTouchTask(
        ssid: _wifiName,
        bssid: _wifiBSSID,
        password: _wifiPassword,
      );
      final Stream<ESPTouchResult> stream = task.execute();
      final printResult = (ESPTouchResult result) {
        print('Configuration complete');
        print('IP: ${result.ip} MAC: ${result.bssid}');
        setState(() {
          _remoteNotifyIPAddress = result.ip;
          _remoteNotifyMacAddress = result.bssid;
          // Reset our buttons too
          buttonStatus = !buttonStatus;
        });
      };
      _streamSubscription = stream.listen(printResult);
      // https://github.com/smaho-engineering/esptouch_flutter_kotlin_example
      // Don't forget to cancel your stream subscription:
      // Future.delayed(Duration(minutes: 1), () => _streamSubscription.cancel());

      // Wait up to one minute for this to complete
      // If you want, you can enable config setting(s) for this like they
      // did in https://github.com/smaho-engineering/esptouch_flutter/tree/master/example
      _timer = new Timer(const Duration(minutes: 1), () {
        print('Timer expired, cancelling stream subscription');
        _streamSubscription.cancel();
        setState(() {
          buttonStatus = !buttonStatus;
        });
      });
    } else {
      print('Missing configuration value');
    }
  }

  void cancelWifiConfig() {
    print('Cancelling Wi-Fi config');
    // _streamSubscription.cancel();
    if (_streamSubscription != null) _streamSubscription.cancel();
    if (_timer.isActive) _timer.cancel();
    setState(() {
      buttonStatus = !buttonStatus;
    });
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

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print('_updateConnectionStatus($result)');
    switch (result) {
      case ConnectivityResult.wifi:
        print('_updateConnectionStatus: Wi-Fi');
        String wifiName, wifiBSSID;

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
          wifiName = "Failed to get Wi-Fi Name";
        }
        print('Wi-Fi Name: $wifiName');

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
          wifiBSSID = "Failed to get Wi-Fi BSSID";
        }
        print('BSSID: $wifiBSSID');

        setState(() {
          _connectionStatus = result.toString();
          _wifiName = wifiName;
          _wifiBSSID = wifiBSSID;
        });
        break;
      case ConnectivityResult.mobile:
        print('_updateConnectionStatus: mobile');
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.none:
        print('_updateConnectionStatus: none');
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        print('_updateConnectionStatus: default');
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadConfigAsync(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Future hasn't finished yet, return a placeholder
            return Scaffold(
                appBar: AppBar(title: Text(widget.title)),
                body: SafeArea(
                    child: Center(
                        child: Container(child: Text('Loading preferences')))));
          } else {
            return Scaffold(
              appBar: AppBar(title: Text(widget.title), actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    print('Refresh tapped');
                    // Are we doing our thing?
                    if (!buttonStatus) cancelWifiConfig();
                    // Let the user know we're refreshing settings
                    Fluttertoast.showToast(
                        msg: "Refreshing network settings...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    initConnectivity();
                    Fluttertoast.cancel();
                  },
                ),
              ]),
              body: SafeArea(
                child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      Text("Connection Status: $_connectionStatus"),
                      Text("Network Name (SSID): $_wifiName"),
                      Text("Base Station ID (BSID): $_wifiBSSID"),
                      SizedBox(height: 10),
                      Text("ESP32 Device"),
                      Text("IP Address: $_remoteNotifyIPAddress"),
                      Text("MAC Address: $_remoteNotifyMacAddress"),
                      SizedBox(height: 10),
                      Text("Wi-Fi Network Password"),
                      SizedBox(height: 10),
                      PasswordField(
                        color: Colors.black,
                        hasFloatingPlaceholder: true,
                        controller: wifiPasswordController,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(width: 2, color: Colors.blueAccent)),
                      ),
                      CheckboxListTile(
                        title: const Text('Save Wi-Fi password'),
                        value: _saveWifiPassword,
                        onChanged: updateCheckValue,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      SizedBox(height: 10),
                      Text("Tap the Push Configuration button to save the " +
                          "Wi-Fi settings to nearby ESP32 devices. " +
                          "Make sure the device is powered on " +
                          "and in SmartConfig mode before tapping " +
                          "the button."),
                      SizedBox(height: 10),
                      Visibility(
                        visible: buttonStatus,
                        child: RaisedButton(
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
                      ),
                      Visibility(
                        visible: !buttonStatus,
                        child: RaisedButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: Colors.black,
                          padding: EdgeInsets.all(8.0),
                          splashColor: Colors.blueAccent,
                          onPressed: cancelWifiConfig,
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ]),
              ),
            );
          }
        });
  }
}
