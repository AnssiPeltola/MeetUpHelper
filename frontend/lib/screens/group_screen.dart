import 'package:flutter/material.dart';
import 'dart:async';
import '../services/group_service.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';
import 'group_settings_screen.dart';
import '../widgets/top_navbar.dart';
import '../services/websocket_service.dart';

class GroupScreen extends StatefulWidget {
  final String token;
  final WebSocketService webSocketService;
  final Function(int) updateInvitationCount;

  const GroupScreen(
      {super.key,
      required this.token,
      required this.webSocketService,
      required this.updateInvitationCount});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<dynamic> groups = [];
  final GroupService _groupService = GroupService();
  int newInvitationsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchNewInvitationsCount();
    widget.webSocketService.onNewInvitation = fetchNewInvitationsCount;
  }

  @override
  void dispose() {
    widget.webSocketService.onNewInvitation = null;
    super.dispose();
  }

  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await _groupService.fetchGroups();
      if (mounted) {
        setState(() {
          groups = fetchedGroups;
        });
      }
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      // Handle error
    }
  }

  Future<void> fetchNewInvitationsCount() async {
    try {
      final count = await _groupService.fetchNewInvitationsCount();
      if (mounted) {
        setState(() {
          newInvitationsCount = count;
          widget.updateInvitationCount(count);
        });
      }
    } catch (e) {
      debugPrint('Error fetching invitations count: $e');
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
