import 'package:flutter/material.dart';
import '../services/group_service.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String token;
  final int groupId;

  const GroupSettingsScreen(
      {Key? key, required this.token, required this.groupId})
      : super(key: key);

  @override
  _GroupSettingsScreenState createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GroupService _groupService = GroupService();
  Map<String, dynamic>? group;
  List<dynamic> members = [];
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserAndGroupDetails();
  }

  Future<void> fetchCurrentUserAndGroupDetails() async {
    try {
      await _groupService.fetchCurrentUser();
      await fetchGroupDetails();
      await fetchCurrentUserRole();
    } catch (e) {
      debugPrint('Error fetching current user and group details: $e');
    }
  }

  Future<void> fetchGroupDetails() async {
    try {
      final fetchedGroup =
          await _groupService.fetchGroupDetails(widget.groupId);
      debugPrint('Fetched group details: $fetchedGroup');
      setState(() {
        group = fetchedGroup;
        members = fetchedGroup['memberships'] ?? [];
        debugPrint('Fetched members: $members');
      });
    } catch (e) {
      debugPrint('Error fetching group details: $e');
    }
  }

  Future<void> fetchCurrentUserRole() async {
    try {
      final role = await _groupService.fetchCurrentUserRole(widget.groupId);
      setState(() {
        currentUserRole = role;
      });
    } catch (e) {
      debugPrint('Error fetching current user role: $e');
    }
  }

  Future<void> _inviteUser() async {
    try {
      final success =
          await _groupService.inviteUser(widget.groupId, _emailController.text);
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User invited successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to invite user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  Future<void> _kickUser(int membershipId) async {
    try {
      final success = await _groupService.kickUser(membershipId);
      if (success) {
        fetchGroupDetails();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User kicked successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to kick user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  Future<void> _deleteGroup() async {
    try {
      final success = await _groupService.deleteGroup(widget.groupId);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group deleted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete group')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  Future<void> _leaveGroup() async {
    try {
      final success = await _groupService.leaveGroup(widget.groupId);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Left the group successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to leave group')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Group'),
          content: Text(
              'Are you sure you want to delete this group? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGroup();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave Group'),
          content: Text(
              'Are you sure you want to leave this group? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveGroup();
              },
              child: Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _showKickUserDialog() async {
    final members = await _groupService.fetchGroupMembers(widget.groupId);
    final nonAdminMembers =
        members.where((member) => member['role'] != 'admin').toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kick User from Group'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nonAdminMembers.length,
              itemBuilder: (context, index) {
                final member = nonAdminMembers[index];
                return ListTile(
                  title: Text(member['user']['username']),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
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
              child: Text('Close'),
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
          title: Text('Confirm Kick User'),
          content:
              Text('Are you sure you want to kick $username from the group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _kickUser(membershipId);
              },
              child: Text('Kick'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUserRole == 'admin';

    return Scaffold(
      appBar: AppBar(title: Text('Group Settings')),
      body: group == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _inviteUser,
                    child: Text('Invite User'),
                  ),
                  if (isAdmin) ...[
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showKickUserDialog,
                      child: Text('Kick User'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showDeleteGroupDialog,
                      child: Text('Delete Group'),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showLeaveGroupDialog,
                    child: Text('Leave Group'),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ListTile(
                          title: Text(member['user']['username']),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => _kickUser(member['id']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
