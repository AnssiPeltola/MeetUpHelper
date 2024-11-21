import 'package:flutter/material.dart';
import '../services/group_service.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';
import 'group_settings_screen.dart';
import 'invitations_screen.dart';

class GroupScreen extends StatefulWidget {
  final String token;

  const GroupScreen({super.key, required this.token});

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
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CreateGroupScreen(token: widget.token)),
              ).then((_) => fetchGroups());
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.mail),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InvitationsScreen(token: widget.token),
                    ),
                  );
                  if (result == true) {
                    fetchGroups();
                    fetchNewInvitationsCount(); // Refresh the count after checking invitations
                  }
                },
              ),
              if (newInvitationsCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$newInvitationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
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
    );
  }
}
