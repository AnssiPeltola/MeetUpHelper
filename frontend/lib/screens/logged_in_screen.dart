import 'package:flutter/material.dart';

class LoggedInScreen extends StatelessWidget {
  final String token;

  LoggedInScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logged In')),
      body: Center(
        child: Text('Welcome! Your token is: $token'),
      ),
    );
  }
}
