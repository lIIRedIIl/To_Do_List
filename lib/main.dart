import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// entry point of the app
void main() {
  runApp(const MyApp());
}

// top-level app widget (sets up material app + first screen)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
