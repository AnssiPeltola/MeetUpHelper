import 'package:flutter/material.dart';

class Link extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Page'),
      ),
      body: Center(
        child: Text('Link to calendar here!'),
      ),
    );
  }
}
