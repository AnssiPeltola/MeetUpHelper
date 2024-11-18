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

  Future<void> _inviteUser() async {
    try {
      final success = await _groupService.inviteUser(
        widget.token,
        widget.groupId,
        _emailController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User invited successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to invite user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Settings')),
      body: Padding(
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
          ],
        ),
      ),
    );
  }
}
