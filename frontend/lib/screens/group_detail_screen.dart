import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../services/group_service.dart';
import 'create_event_screen.dart';
import 'chat_screen.dart';
import 'group_settings_screen.dart';
import 'day_view_screen.dart';

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
  Map<int, Color> userColors = {};

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
    fetchCurrentUser();
  }

  Future<void> fetchGroupDetails() async {
    try {
      final fetchedGroup =
          await _groupService.fetchGroupDetails(widget.groupId);
      final members = await _groupService.fetchGroupMembers(widget.groupId);
      debugPrint('Fetched group details: $fetchedGroup');
      setState(() {
        group = fetchedGroup;
        events = fetchedGroup['events'] ?? [];
        userColors = _assignColorsToUsers(members);
        debugPrint('User colors: $userColors');
        debugPrint('Fetched events: $events');
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching group details: $e');
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      await _groupService.fetchCurrentUser();
      setState(() {
        debugPrint('Current User ID: ${_groupService.currentUserId}');
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching current user: $e');
    }
  }

  Color generateColor(int index, int total) {
    final hue = (index * 360 / total) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  Map<int, Color> _assignColorsToUsers(List<dynamic> members) {
    Map<int, Color> userColors = {};
    int totalMembers = members.length;

    for (int i = 0; i < members.length; i++) {
      int userId = members[i]['user']['id'];
      userColors[userId] = generateColor(i, totalMembers);
    }

    return userColors;
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
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: EventDataSource(
                  events, userColors, _groupService.currentUserId),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayViewScreen(
                        token: widget.token,
                        groupId: widget.groupId,
                        selectedDate: details.date!,
                        events: events,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
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
              child: const Text('Make New Event'),
            ),
          ),
        ],
      ),
      ChatScreen(token: widget.token, groupId: widget.groupId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(group?['name'] ?? 'Group Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsScreen(
                    token: widget.token,
                    groupId: widget.groupId,
                  ),
                ),
              );
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
  final Map<int, Color> userColors;
  final int? currentUserId;

  EventDataSource(List<dynamic> source, this.userColors, this.currentUserId) {
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
    int? userId = appointments![index]['created_by'];
    debugPrint(
        'Event index: $index, User ID: $userId, Current User ID: $currentUserId');
    if (userId == null) {
      return Colors.grey;
    }
    if (userId == currentUserId) {
      return Colors.blue;
    }
    return userColors[userId] ?? Colors.grey;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
