import 'package:flutter/material.dart';
import 'dart:async';
import 'group_screen.dart';

class LoggedInScreen extends StatelessWidget {
  final String username;
  final String token;

  const LoggedInScreen(
      {super.key, required this.username, required this.token});

  @override
  Widget build(BuildContext context) {
    // Navigate to the group screen after 3 seconds with a fade transition
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GroupScreen(token: token),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Logged In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome $username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your token is:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  token,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
