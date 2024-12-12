import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/group_service.dart';

class EventDetailScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> event;

  const EventDetailScreen(
      {super.key, required this.token, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? creatorUsername;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    fetchCreatorUsername();
  }

  Future<void> fetchCreatorUsername() async {
    try {
      final username =
          await _groupService.fetchCreatorUsername(widget.event['created_by']);
      setState(() {
        creatorUsername = username;
      });
    } catch (e) {
      setState(() {
        creatorUsername = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime = DateTime.parse(widget.event['start_time']);
    DateTime endTime = DateTime.parse(widget.event['end_time']);
    String formattedStartTime =
        DateFormat('EEEE d. MMMM HH:mm').format(startTime);
    String formattedEndTime = DateFormat('EEEE d. MMMM HH:mm').format(endTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Description: ${widget.event['description'] ?? 'No description'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Start Time: $formattedStartTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'End Time: $formattedEndTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Created By: ${creatorUsername ?? 'Loading...'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
