import 'package:flutter/material.dart';
import '../services/group_service.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String token;
  final int groupId;

  const GroupSettingsScreen(
      {super.key, required this.token, required this.groupId});

  @override
  _GroupSettingsScreenState createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GroupService _groupService = GroupService();
  Map<String, dynamic>? group;
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();
    fetchCurrentUserAndGroupDetails();
  }

  Future<void> fetchCurrentUserAndGroupDetails() async {
    try {
      await _groupService.fetchCurrentUser(widget.token);
      await fetchGroupDetails();
    } catch (e) {
      debugPrint('Error fetching current user and group details: $e');
    }
  }

  Future<void> fetchGroupDetails() async {
    try {
      final fetchedGroup =
          await _groupService.fetchGroupDetails(widget.token, widget.groupId);
      debugPrint('Fetched group details: $fetchedGroup'); // Add logging here
      setState(() {
        group = fetchedGroup;
        members = fetchedGroup['memberships'] ?? [];
        debugPrint('Fetched members: $members'); // Add logging here
      });
    } catch (e) {
      debugPrint('Error fetching group details: $e');
    }
  }

  Future<void> _inviteUser() async {
    try {
      final success = await _groupService.inviteUser(
          widget.token, widget.groupId, _emailController.text);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User invited successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to invite user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  Future<void> _kickUser(int membershipId) async {
    try {
      final success = await _groupService.kickUser(widget.token, membershipId);
      if (success) {
        fetchGroupDetails();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User kicked successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to kick user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  void _showKickUserDialog() async {
    final members =
        await _groupService.fetchGroupMembers(widget.token, widget.groupId);
    final nonAdminMembers =
        members.where((member) => member['role'] != 'admin').toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kick User from Group'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nonAdminMembers.length,
              itemBuilder: (context, index) {
                final member = nonAdminMembers[index];
                return ListTile(
                  title: Text(member['user']['username']),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmKickUser(
                          member['id'], member['user']['username']);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmKickUser(int membershipId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Kick User'),
          content:
              Text('Are you sure you want to kick $username from the group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _kickUser(membershipId);
              },
              child: const Text('Kick'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = group?['created_by']['id'] == _groupService.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Group Settings')),
      body: group == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _inviteUser,
                    child: const Text('Invite User'),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showKickUserDialog,
                      child: const Text('Kick User'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Add delete group functionality
                      },
                      child: const Text('Delete Group'),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            title: Text(member['user']['username']),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _kickUser(member['id']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
