import 'package:flutter/material.dart';
import 'package:scorescope/views/all_matches.dart';
import 'services/repositories/mock_match_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final repo = MockMatchRepository();
    return MaterialApp(
      title: 'ScoreScope',
      theme: ThemeData(
        primaryColor: Colors.green,
        secondaryHeaderColor: Colors.lightGreen
      ),
      home: AllMatchesView(repository: repo),
    );
  }
}