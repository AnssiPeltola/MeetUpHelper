import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateCalendarScreen extends StatefulWidget {
  @override
  _CreateCalendarScreenState createState() => _CreateCalendarScreenState();
}

class _CreateCalendarScreenState extends State<CreateCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Calendar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Calendar Name',
                border: OutlineInputBorder(),
              ),
              // Regex to only allow alphanumeric characters. Also blocking spaces.
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              // Add backend controller and logic as needed later on
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Create Calendar'),
              onPressed: () {
                // Add create calendar logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
