import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String token;

  const ChatScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow icon
      ),
      body: Center(
        child: Text('Chat Screen'),
      ),
    );
  }
}
