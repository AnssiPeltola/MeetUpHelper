import 'package:flutter/material.dart';
import '../services/group_service.dart';

class InvitationsScreen extends StatefulWidget {
  final String token;

  const InvitationsScreen({super.key, required this.token});

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  List<dynamic> invitations = [];
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    fetchInvitations();
  }

  Future<void> fetchInvitations() async {
    try {
      final fetchedInvitations =
          await _groupService.fetchInvitations(widget.token);
      setState(() {
        invitations = fetchedInvitations;
      });
      debugPrint('Fetched invitations: $invitations');
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load invitations')),
      );
    }
  }

  Future<void> _acceptInvitation(int invitationId) async {
    try {
      final success =
          await _groupService.acceptInvitation(widget.token, invitationId);
      if (success) {
        fetchInvitations();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation accepted')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept invitation')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> _rejectInvitation(int invitationId) async {
    try {
      final success =
          await _groupService.rejectInvitation(widget.token, invitationId);
      if (success) {
        fetchInvitations();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation rejected')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reject invitation')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: ListView.builder(
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          final group = invitation['group'] ?? {};
          final createdBy = group['created_by'] ?? {};

          return ListTile(
            title: Text(group['name'] ?? 'Unknown Group'),
            subtitle: Text('Invited by: ${createdBy['username'] ?? 'Unknown'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _acceptInvitation(invitation['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _rejectInvitation(invitation['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
