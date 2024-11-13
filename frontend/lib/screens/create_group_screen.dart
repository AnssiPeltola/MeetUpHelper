import 'package:flutter/material.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  final String token;

  CreateGroupScreen({required this.token});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GroupService _groupService = GroupService();

  Future<void> _createGroup() async {
    final success = await _groupService.createGroup(
      widget.token,
      _nameController.text,
      _descriptionController.text,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
