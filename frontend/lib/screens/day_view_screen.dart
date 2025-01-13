import 'package:flutter/material.dart';
import 'event_detail_screen.dart';

class DayViewScreen extends StatelessWidget {
  final String token;
  final int groupId;
  final DateTime selectedDate;
  final List<dynamic> events;

  const DayViewScreen({
    super.key,
    required this.token,
    required this.groupId,
    required this.selectedDate,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the selectedDate is at midnight for accurate comparisons
    DateTime dayStart =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    // Filter events that overlap the selectedDate
    List<dynamic> dayEvents = events.where((event) {
      DateTime startTime = DateTime.parse(event['start_time']);
      DateTime endTime = DateTime.parse(event['end_time']);
      return startTime.isBefore(dayEnd) && endTime.isAfter(dayStart);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Events on ${selectedDate.toLocal()}'.split(' ')[0]),
      ),
      body: ListView.builder(
        itemCount: dayEvents.length,
        itemBuilder: (context, index) {
          final event = dayEvents[index];
          return ListTile(
            title: Text(event['title']),
            subtitle: Text(event['description'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(
                    token: token,
                    event: event,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
