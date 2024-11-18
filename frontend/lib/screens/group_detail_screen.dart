import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../services/group_service.dart';
import 'create_event_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String token;
  final int groupId;

  GroupDetailScreen({required this.token, required this.groupId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Map<String, dynamic>? group;
  List<dynamic> events = [];
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    try {
      final fetchedGroup =
          await _groupService.fetchGroupDetails(widget.token, widget.groupId);
      setState(() {
        group = fetchedGroup;
        events = fetchedGroup['events'] ?? [];
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group?['name'] ?? 'Group Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEventScreen(
                    token: widget.token,
                    groupId: widget.groupId,
                  ),
                ),
              ).then((_) => fetchGroupDetails());
            },
          ),
        ],
      ),
      body: group == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(group!['description'] ?? ''),
                ),
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.month,
                    dataSource: EventDataSource(events),
                    monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<dynamic> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.parse(appointments![index]['start_time']);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime.parse(appointments![index]['end_time']);
  }

  @override
  String getSubject(int index) {
    return appointments![index]['title'];
  }

  @override
  Color getColor(int index) {
    return Colors.blue;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
