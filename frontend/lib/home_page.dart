import 'package:flutter/material.dart';
import 'package:frontend/calendar.dart';
import 'package:frontend/calendar_link.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MeetUp Helper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('MeetUp Helper Logo here!'),
            ElevatedButton(
              child: Text('Create New Calendar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Calendar()),
                );
              },
            ),
            SizedBox(height: 20), // Add 20 pixels of space

            ElevatedButton(
              child: Text('Join Calendar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Link()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
