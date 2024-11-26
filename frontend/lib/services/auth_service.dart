import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<Map<String, String>?> registerUser(
      String email, String username, String password, String password2) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/register/'),
      body: {
        "email": email,
        "username": username,
        "password": password,
        "password2": password2,
      },
    );

    if (response.statusCode == 201) {
      // Automatically log in the user after successful registration
      return await loginUser(username, password);
    } else {
      return null;
    }
  }

  Future<Map<String, String>?> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login/'),
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'username': username,
        'token': data['access'],
      }; // Return the username and JWT token
    } else {
      return null;
    }
  }
}
