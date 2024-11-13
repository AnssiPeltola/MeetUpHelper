import 'package:flutter/material.dart';
import '../services/group_service.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

class GroupScreen extends StatefulWidget {
  final String token;

  GroupScreen({required this.token});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<dynamic> groups = [];
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    fetchGroups();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CreateGroupScreen(token: widget.token)),
              ).then((_) => fetchGroups());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groups[index]['name']),
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
