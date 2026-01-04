import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  // entry point: this starts the app and mounts the first widget tree
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // materialapp is the wrapper that gives you navigation, theme, etc
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'to do list',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
