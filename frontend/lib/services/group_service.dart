import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class GroupService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  int? currentUserId;
  final AuthService _authService = AuthService();

  Future<List<dynamic>> fetchGroups() async {
    final token = await _authService.getValidToken();
    if (token == null) {
      debugPrint('No valid token available');
      throw Exception('No valid token available');
    }

    debugPrint('Using token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/groups/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<bool> createGroup(String name, String description) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<Map<String, dynamic>> fetchGroupDetails(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      debugPrint('No valid token available');
      throw Exception('No valid token available');
    }

    final url = Uri.parse('$baseUrl/groups/$groupId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final groupData = json.decode(response.body);
      debugPrint('Fetched group data: $groupData');
      return groupData;
    } else {
      throw Exception('Failed to load group details');
    }
  }

  Future<List<dynamic>> fetchGroupMembers(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      debugPrint('No valid token available');
      throw Exception('No valid token available');
    }

    final url = Uri.parse('$baseUrl/groups/$groupId/members/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final membersData = json.decode(response.body);
      debugPrint('Fetched group members: $membersData');
      return membersData;
    } else {
      throw Exception('Failed to load group members');
    }
  }

  Future<List<dynamic>> fetchGroupEvents(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      debugPrint('No valid token available');
      throw Exception('No valid token available');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/events/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load group events');
    }
  }

  Future<bool> createEvent(int groupId, String title, String description,
      DateTime startTime, DateTime endTime) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

    final url = '$baseUrl/groups/events/create/';
    debugPrint(
        'Sending POST request to $url with data: {group: $groupId, title: $title, description: $description, start_time: ${startTime.toIso8601String()}, end_time: ${endTime.toIso8601String()}}');

    final response = await http.post(
      Uri.parse(url),
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

  Future<bool> inviteUser(int groupId, String email) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<List<dynamic>> fetchInvitations() async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<bool> acceptInvitation(int invitationId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<bool> rejectInvitation(int invitationId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<bool> kickUser(int membershipId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<void> fetchCurrentUser() async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<String?> fetchCurrentUserRole(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<bool> deleteGroup(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<int> fetchNewInvitationsCount() async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<bool> leaveGroup(int groupId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

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

  Future<String?> fetchCreatorUsername(int userId) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw Exception('No valid token available');
    }

    final url = Uri.parse('$baseUrl/accounts/user/$userId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['username'];
    } else {
      throw Exception('Failed to fetch creator username');
    }
  }
}
