import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String token;
  final int groupId;

  ChatScreen({required this.token, required this.groupId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  final Map<int, String> _usernamesCache = {};
  final ScrollController _scrollController = ScrollController();
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.extractUserIdFromToken(widget.token);
    _fetchChatMessages();
    _connectToChat();
  }

  void _connectToChat() {
    final uri = Uri.parse(
        'ws://192.168.1.211:8000/ws/chat/${widget.groupId}/?token=${widget.token}');
    _channel = IOWebSocketChannel.connect(uri);

    _channel.stream.listen((message) {
      final data = json.decode(message);
      setState(() {
        _messages.add(data);
      });
      _scrollToBottom();
    }, onDone: () {
      debugPrint('WebSocket chat connection closed');
    }, onError: (error) {
      debugPrint('WebSocket chat error: $error');
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {'message': _controller.text};
      _channel.sink.add(json.encode(message));
      _controller.clear();
    }
  }

  Future<void> _fetchChatMessages() async {
    try {
      final messages = await _groupService.fetchChatMessages(widget.groupId);
      setState(() {
        _messages.addAll(messages);
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
    }
  }

  Future<String> _fetchUsername(int userId) async {
    if (_usernamesCache.containsKey(userId)) {
      return _usernamesCache[userId]!;
    }
    try {
      final user = await _groupService.fetchUserDetails(userId);
      _usernamesCache[userId] = user['username'];
      return user['username'];
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'Unknown';
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final userId = message['user'];
                final isMe = userId == _currentUserId;
                if (userId is String) {
                  debugPrint('Error: userId is a String: $userId');
                  // Attempt to parse the userId as an integer
                  try {
                    final parsedUserId = int.parse(userId);
                    return _buildMessageTile(message, parsedUserId, isMe);
                  } catch (e) {
                    debugPrint('Failed to parse userId: $e');
                    return ListTile(
                      title: Text('Error'),
                      subtitle: Text(message['message']),
                    );
                  }
                } else if (userId is int) {
                  debugPrint('userId is an int: $userId');
                  return _buildMessageTile(message, userId, isMe);
                } else {
                  debugPrint('Unexpected userId type: ${userId.runtimeType}');
                  return ListTile(
                    title: Text('Error'),
                    subtitle: Text(message['message']),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
      Map<String, dynamic> message, int userId, bool isMe) {
    return FutureBuilder<String>(
      future: _fetchUsername(userId),
      builder: (context, snapshot) {
        final username = snapshot.data ?? 'Loading...';
        final formattedTimestamp = _formatTimestamp(message['timestamp']);
        return MessageBubble(
          message: message['message'],
          username: username,
          timestamp: formattedTimestamp,
          isMe: isMe,
        );
      },
    );
  }
}
