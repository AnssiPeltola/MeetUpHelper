import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  String? accessToken;
  String? refreshToken;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

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
      accessToken = data['access'];
      refreshToken = data['refresh'];
      debugPrint(
          'Login successful. Access token: $accessToken, Refresh token: $refreshToken');
      return {
        'username': username,
        'token': accessToken!,
      };
    } else {
      debugPrint(
          'Login failed. Status code: ${response.statusCode}, Body: ${response.body}');
      return null;
    }
  }

  Future<String?> refreshAccessToken() async {
    if (refreshToken == null) {
      debugPrint('No refresh token available');
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/token/refresh/'),
      body: {
        "refresh": refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      accessToken = data['access'];
      debugPrint('Token refreshed. New access token: $accessToken');
      return accessToken;
    } else {
      debugPrint(
          'Failed to refresh token. Status code: ${response.statusCode}, Body: ${response.body}');
      return null;
    }
  }

  Future<String?> getValidToken() async {
    if (accessToken == null) {
      debugPrint('No access token available');
      return null;
    }

    // Decode token and check expiration
    final payload = _decodeJWT(accessToken!);
    final exp = payload['exp'];
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    debugPrint('Current timestamp: $currentTimestamp, Token expiration: $exp');

    if (currentTimestamp > exp) {
      // Token expired, refresh it
      debugPrint('Token expired. Refreshing token...');
      return await refreshAccessToken();
    }
    return accessToken;
  }

  Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return json.decode(payload);
  }

  int extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payload);
      if (payloadMap.containsKey('user_id')) {
        return payloadMap['user_id'];
      } else {
        throw Exception('user_id not found in token');
      }
    } catch (e) {
      debugPrint('Error extracting user ID from token: $e');
      throw Exception('Failed to extract user ID from token');
    }
  }
}
