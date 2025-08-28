// lib/pages/user_transactions_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserTransactionsPage extends StatelessWidget {
  const UserTransactionsPage({super.key});

  Color _statusColor(String status) {
    if (status == 'Confirmed') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    final stream = FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
    
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No transactions yet'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final status = (d['status'] as String?) ?? 'Pending';
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(status).withOpacity(0.12),
                    child: Icon(Icons.payment, color: _statusColor(status)),
                  ),
                  title: Text('${d['method'] ?? ''} • ${d['amount']?.toString() ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ref: ${d['reference'] ?? '-'}'),
                      Text('Submitted: ${d['createdAtReadable'] ?? ''}'),
                      if (d['confirmedBy'] != null) Text('Confirmed by: ${d['confirmedBy']}'),
                    ],
                  ),
                  trailing: Text(status, style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
                  onTap: () {
                    // optionally show details dialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('${d['method'] ?? ''} Payment'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Amount: ${d['amount'] ?? ''}'),
                            Text('Ref: ${d['reference'] ?? ''}'),
                            if (d['screenshotUrl'] != null && (d['screenshotUrl'] as String).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Image.network(d['screenshotUrl']),
                              ),
                          ],
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
