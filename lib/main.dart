import 'package:flutter/material.dart';

/// entry point of the app
void main() {
  runApp(const myApp());
}

/// root widget of the application
class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    // sets up theme and first screen
    return MaterialApp(
      title: 'to do list',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const homeScreen(),
    );
  }
}

/// first screen shown when the app starts
class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // basic page structure
    return const Scaffold(
      body: Center(
        child: Text(
          'web is running 🚀',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
