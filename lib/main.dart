import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: homeScreen(),
    );
  }
}
