import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../services/group_service.dart';
import 'create_event_screen.dart';
import 'chat_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String token;
  final int groupId;

  const GroupDetailScreen(
      {super.key, required this.token, required this.groupId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Map<String, dynamic>? group;
  List<dynamic> events = [];
  final GroupService _groupService = GroupService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    try {
      final fetchedGroup =
          await _groupService.fetchGroupDetails(widget.token, widget.groupId);
      debugPrint('Fetched group details: $fetchedGroup');
      setState(() {
        group = fetchedGroup;
        events = fetchedGroup['events'] ?? [];
        debugPrint('Fetched events: $events');
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching group details: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(group?['description'] ?? ''),
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: EventDataSource(events),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ],
      ),
      ChatScreen(token: widget.token),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(group?['name'] ?? 'Group Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
