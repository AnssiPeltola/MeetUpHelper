import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String token;

  const SettingsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
