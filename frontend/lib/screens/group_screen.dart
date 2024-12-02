import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/group_service.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';
import 'group_settings_screen.dart';
import '../widgets/top_navbar.dart';

class GroupScreen extends StatefulWidget {
  final String token;
  final Function(int) updateInvitationCount;

  const GroupScreen(
      {super.key, required this.token, required this.updateInvitationCount});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<dynamic> groups = [];
  final GroupService _groupService = GroupService();
  int newInvitationsCount = 0;
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchNewInvitationsCount();
    connectWebSocket();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void connectWebSocket() {
    final uri = Uri.parse(
        'ws://192.168.1.211:8000/ws/notifications/?token=${widget.token}');

    channel = IOWebSocketChannel.connect(uri);

    channel.stream.listen((message) async {
      debugPrint("Received message: $message");
      final data = json.decode(message);
      debugPrint('Received WebSocket message: $data');

      if (data != null &&
          data.containsKey('title') &&
          data.containsKey('body')) {
        // Check for "New Invitation" notification
        if (data['title'] == 'New Invitation') {
          fetchNewInvitationsCount(); // Update invitation count

          // Show a local notification
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'group_invites_channel', // channelId
            'Group Invites', // channelName
            channelDescription:
                'Notifications for group invites', // description
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          await flutterLocalNotificationsPlugin.show(
            0, // Notification ID
            data['title'], // Notification title
            data['body'], // Notification body
            platformChannelSpecifics,
          );
        }
      } else {
        debugPrint('Received invalid WebSocket message: $data');
      }
    });
  }

  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await _groupService.fetchGroups(widget.token);
      setState(() {
        groups = fetchedGroups;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchNewInvitationsCount() async {
    try {
      final count = await _groupService.fetchNewInvitationsCount(widget.token);
      setState(() {
        newInvitationsCount = count;
        widget.updateInvitationCount(count);
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        token: widget.token,
        title: 'Groups',
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchGroups();
                await fetchNewInvitationsCount();
              },
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(groups[index]['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupSettingsScreen(
                              token: widget.token,
                              groupId: groups[index]['id'],
                            ),
                          ),
                        );
                        if (result == true) {
                          fetchGroups(); // Refresh groups if a group was deleted
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailScreen(
                            token: widget.token,
                            groupId: groups[index]['id'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupScreen(token: widget.token)),
                ).then((_) => fetchGroups());
              },
              child: const Text('New Calendar Group'),
            ),
          ),
        ],
      ),
    );
  }
}
