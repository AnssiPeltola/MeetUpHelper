import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(MeetUpHelperApp());
}

class MeetUpHelperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetUp Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(), // Your custom home page widget
    );
  }
}
