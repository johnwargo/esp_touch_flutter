// ignore_for_file: public_member_api_docs
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';

void main() => runApp(EspTouchApp());

// Sets a platform override for desktop to avoid exceptions. See
// https://flutter.dev/desktop#target-platform-override for more info.
void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

class EspTouchApp extends StatelessWidget {

  String appName = 'ESP Touch (Flutter)';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EspTouchHome(appName: appName),
    );
  }
}
