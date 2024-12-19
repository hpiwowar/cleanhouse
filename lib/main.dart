import 'package:flutter/material.dart';
import 'package:cleanhouse/pages/CleaningListPage.dart';

void main() {
  runApp(const CleaningApp());
}

class CleaningApp extends StatelessWidget {
  const CleaningApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean clean clean',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: Colors.deepOrangeAccent,
        ),
        fontFamily: 'Varela',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 18.0, fontFamily: 'Varela'),
        ),
      ),
      home: const CleaningListPage(title: 'cleaning cleaning'),
    );
  }
}




