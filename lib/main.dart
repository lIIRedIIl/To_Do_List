

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  // starts the Flutter app
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

   
      title: 'To Do List',

      //theme for the whole app
      theme: ThemeData(
    
        useMaterial3: true,

        //background
        scaffoldBackgroundColor: const Color(0xFFF6F1F8),

        //colour used by buttons, toggles, checkboxes.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB08968), //brown
        ),

        //theme (top banner)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2233),
          ),
        ),

        //makecards look soft and rounded everywhere in the app

        cardTheme: CardThemeData(

          color: Colors.white, 
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        //syling for checkboxes
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        // default text styling
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2B2233),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF2B2233),
          ),
        ),
      ),

      // the  screen the app shows
      home: const HomeScreen(),
    );
  }
}
//