import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String username;
  final String timestamp;
  final bool isMe;

  MessageBubble({
    required this.message,
    required this.username,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.9, // 90% of the available width
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
