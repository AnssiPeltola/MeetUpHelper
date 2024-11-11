import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<bool> registerUser(
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

    return response.statusCode == 201;
  }

  Future<String?> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login/'),
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access']; // Return the JWT token
    } else {
      return null;
    }
  }
}
