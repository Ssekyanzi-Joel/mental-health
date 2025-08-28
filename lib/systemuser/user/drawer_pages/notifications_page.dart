import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(25, 53, 30, 0.1),
                    Color.fromRGBO(45, 83, 50, 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: Color.fromRGBO(25, 53, 30, 1.0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Notifications Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(25, 53, 30, 1.0),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'re all caught up! New notifications will appear here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(25, 53, 30, 1.0),
                  Color.fromRGBO(35, 73, 40, 1.0),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(25, 53, 30, 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    DocumentSnapshot notification,
    BuildContext context,
    int index,
  ) {
    bool read = notification['read'] ?? false;
    String title = notification['title'] ?? '';
    String body = notification['body'] ?? '';
    Timestamp? timestamp = notification['timestamp'] as Timestamp?;

    String timeAgo = '';
    if (timestamp != null) {
      Duration difference = DateTime.now().difference(timestamp.toDate());
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: read ? Colors.white : const Color.fromRGBO(25, 53, 30, 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: read
              ? Colors.grey.shade200
              : const Color.fromRGBO(25, 53, 30, 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: read
                  ? [Colors.grey.shade300, Colors.grey.shade400]
                  : [
                      const Color.fromRGBO(45, 83, 50, 1.0),
                      const Color.fromRGBO(25, 53, 30, 1.0),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getNotificationIcon(title),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: read ? FontWeight.w500 : FontWeight.bold,
                  fontSize: 16,
                  color: read
                      ? Colors.grey.shade700
                      : const Color.fromRGBO(25, 53, 30, 1.0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!read) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(25, 53, 30, 1.0),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (timeAgo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        onTap: () async {
          if (!read) {
            await notification.reference.update({'read': true});
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('appointment') || lowerTitle.contains('session')) {
      return Icons.event_outlined;
    } else if (lowerTitle.contains('message') || lowerTitle.contains('chat')) {
      return Icons.message_outlined;
    } else if (lowerTitle.contains('reminder')) {
      return Icons.alarm_outlined;
    } else if (lowerTitle.contains('update') || lowerTitle.contains('new')) {
      return Icons.update_outlined;
    } else {
      return Icons.notifications_outlined;
    }
  }

  Widget _buildHeaderStats(int totalCount, int unreadCount) {
    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(25, 53, 30, 1.0),
            Color.fromRGBO(35, 73, 40, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(25, 53, 30, 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0
                      ? '$unreadCount unread of $totalCount total'
                      : 'All $totalCount notifications read',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromRGBO(25, 53, 30, 1.0),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: () async {
                  final batch = firestore.batch();
                  for (var doc in snapshot.data!.docs) {
                    batch.update(doc.reference, {'read': true});
                  }
                  await batch.commit();
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          var notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          int unreadCount = notifications
              .where((doc) => !(doc['read'] ?? false))
              .length;

          return Column(
            children: [
              _buildHeaderStats(notifications.length, unreadCount),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(
                      notifications[index],
                      context,
                      index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
