import 'package:flutter/material.dart';
import './pages/home.dart';

void main() => runApp(EspTouchApp());

class EspTouchApp extends StatelessWidget {
  String appName = 'ESP Touch Testing';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EspTouchHome(appName: appName),
    );
  }
}
