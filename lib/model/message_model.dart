import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime time;
  final String? replyTo;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
    this.replyTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(time),
      'replyTo': replyTo,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] ?? '',
      isUser: map['isUser'] ?? true,
      time: (map['timestamp'] as Timestamp).toDate(),
      replyTo: map['replyTo'],
    );
  }
}
