import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// entry point of the application
void main() {
  // starts the app and attaches the widget tree
  runApp(const myApp());
}

/// root widget of the app
/// responsible for app-wide setup
class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // first screen shown when the app starts
      home: homeScreen(),
    );
  }
}
 