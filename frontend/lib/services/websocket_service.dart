import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  bool _isConnected = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Function? onNewInvitation;
  final AuthService _authService = AuthService();

  WebSocketService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void connect() async {
    if (_isConnected) return;

    final token = await _authService.getValidToken();
    if (token == null) {
      debugPrint('No valid token available for WebSocket');
      return;
    }

    final uri =
        Uri.parse('ws://192.168.1.211:8000/ws/notifications/?token=$token');
    _channel = IOWebSocketChannel.connect(uri);

    _channel.stream.listen((message) async {
      debugPrint("Received message: $message");
      final data = json.decode(message);
      debugPrint('Received WebSocket message: $data');

      if (data != null &&
          data.containsKey('title') &&
          data.containsKey('body')) {
        // Handle WebSocket messages here
        if (data['title'] == 'New Invitation') {
          // Show a local notification
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'group_invites_channel', // channelId
            'Group Invites', // channelName
            channelDescription:
                'Notifications for group invites', // description
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          await flutterLocalNotificationsPlugin.show(
            0, // Notification ID
            data['title'], // Notification title
            data['body'], // Notification body
            platformChannelSpecifics,
          );

          // Call the callback function if set
          if (onNewInvitation != null) {
            onNewInvitation!();
          }
        }
      } else {
        debugPrint('Received invalid WebSocket message: $data');
      }
    }, onDone: () {
      debugPrint('WebSocket connection closed');
      _isConnected = false;
    }, onError: (error) {
      debugPrint('WebSocket error: $error');
      _isConnected = false;
    });

    _isConnected = true;
    debugPrint('WebSocket connected');
  }

  void disconnect() {
    if (_isConnected) {
      _channel.sink.close();
      _isConnected = false;
      debugPrint('WebSocket disconnected');
    }
  }

  WebSocketChannel get channel => _channel;
}
