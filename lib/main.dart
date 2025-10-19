import 'package:flutter/material.dart';
import 'package:scorescope/views/all_matches.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScoreScope',
      theme: ThemeData(
        primaryColor: Colors.green,
        secondaryHeaderColor: Colors.lightGreen
      ),
      home: AllMatchesView(),
    );
  }
}