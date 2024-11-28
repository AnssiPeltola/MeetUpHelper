import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroupService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  int? currentUserId;

  Future<List<dynamic>> fetchGroups(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<bool> createGroup(
      String token, String name, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed to create group: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchGroupDetails(
      String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final groupData = json.decode(response.body);
      debugPrint('Fetched group data: $groupData');
      return groupData;
    } else {
      throw Exception('Failed to load group details');
    }
  }

  Future<List<dynamic>> fetchGroupMembers(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/members/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final membersData = json.decode(response.body);
      debugPrint('Fetched group members: $membersData');
      return membersData;
    } else {
      throw Exception('Failed to load group members');
    }
  }

  Future<List<dynamic>> fetchGroupEvents(String token, int groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/events/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load group events');
    }
  }

  Future<bool> createEvent(String token, int groupId, String title,
      String description, DateTime startTime, DateTime endTime) async {
    final url = Uri.parse('$baseUrl/groups/events/create/');
    debugPrint(
        'Sending POST request to $url with data: {group: $groupId, title: $title, description: $description, start_time: ${startTime.toIso8601String()}, end_time: ${endTime.toIso8601String()}}');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'group': groupId,
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('Event created successfully');
      return true;
    } else {
      debugPrint('Failed to create event: ${response.body}');
      return false;
    }
  }

  Future<bool> inviteUser(String token, int groupId, String email) async {
    final url = Uri.parse('$baseUrl/groups/invite/');
    debugPrint(
        'Sending POST request to $url with data: {group_id: $groupId, email: $email}');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'group_id': groupId,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('User invited successfully');
      return true;
    } else {
      debugPrint('Failed to invite user: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> fetchInvitations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/invitations/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load invitations');
    }
  }

  Future<bool> acceptInvitation(String token, int invitationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/invite/accept/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'invitation_id': invitationId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Failed to accept invitation: ${response.body}');
      return false;
    }
  }

  Future<bool> rejectInvitation(String token, int invitationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/invite/reject/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'invitation_id': invitationId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Failed to reject invitation: ${response.body}');
      return false;
    }
  }

  Future<bool> kickUser(String token, int membershipId) async {
    final url = Uri.parse('$baseUrl/groups/kick/$membershipId/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('User kicked successfully');
      return true;
    } else {
      debugPrint('Failed to kick user: ${response.body}');
      return false;
    }
  }

  Future<void> fetchCurrentUser(String token) async {
    final url = Uri.parse('$baseUrl/accounts/me/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      debugPrint('Fetched current user data: $userData');
      currentUserId = userData['id'];
      debugPrint('Current user ID: $currentUserId');
    } else {
      throw Exception('Failed to load current user details');
    }
  }

  Future<String?> fetchCurrentUserRole(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/members/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final member = data.firstWhere(
          (member) => member['user']['id'] == currentUserId,
          orElse: () => null);
      return member != null ? member['role'] : null;
    } else {
      throw Exception('Failed to fetch current user role');
    }
  }

  Future<bool> deleteGroup(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/delete/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      debugPrint('Group deleted successfully');
      return true;
    } else {
      debugPrint('Failed to delete group: ${response.body}');
      return false;
    }
  }

  Future<int> fetchNewInvitationsCount(String token) async {
    final url = Uri.parse('$baseUrl/groups/invitations/count/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['new_invitations_count'];
    } else {
      throw Exception('Failed to load new invitations count');
    }
  }

  Future<bool> leaveGroup(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/leave/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'group_id': groupId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
