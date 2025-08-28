import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String authorName;
  final String text;
  final String mediaUrl;
  final String mediaType;
  final DateTime timestamp;

  Post({
    required this.authorName,
    required this.text,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      authorName: data['authorName'] ?? 'Unknown',
      text: data['text'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'text',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
