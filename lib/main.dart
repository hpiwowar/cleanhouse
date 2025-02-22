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
      debugShowCheckedModeBanner: false,
      title: 'moompda clean',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.pink.shade300,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey.shade200,
          secondary: Colors.deepOrange,
        ),
        fontFamily: 'Varela',
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   titleLarge: TextStyle(fontSize: 36.0),
        //   bodyMedium: TextStyle(fontSize: 18.0, fontFamily: 'Varela'),
        // ),
      ),
      home: const CleaningListPage(title: 'Mere Moments per Day!'),
    );
  }
}
