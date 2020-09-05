import 'package:flutter/material.dart';

import './pages/home.dart';

const APP_NAME = 'ESP Touch (Flutter)';

void main() {
  runApp(EspTouchApp());
}

class EspTouchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: EspTouchHome(title: APP_NAME),
    );
  }
}
