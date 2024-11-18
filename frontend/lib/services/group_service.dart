import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroupService {
  final String baseUrl = dotenv.env['BASE_URL']!;

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
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load group details');
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
}
