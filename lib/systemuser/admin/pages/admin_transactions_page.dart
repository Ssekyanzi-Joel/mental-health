// lib/pages/admin_transactions_page.dart
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminTransactionsPage extends StatelessWidget {
  const AdminTransactionsPage({super.key});

  Color _statusColor(String status) {
    if (status == 'Confirmed') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.grey;
  }

  Future<void> _updateStatus(BuildContext context, String docId, String status) async {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }
    await FirebaseFirestore.instance.collection('payments').doc(docId).update({
      'status': status,
      'confirmedBy': admin.uid,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('payments').orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('All Payments (Admin)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No payments found'));

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
                    child: Icon(Icons.account_balance_wallet, color: _statusColor(status)),
                  ),
                  title: Text('${d['userName'] ?? 'User'} • ${d['method'] ?? ''} • ${d['amount'] ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${d['phone'] ?? '-'}'),
                      Text('Ref: ${d['reference'] ?? '-'}'),
                      Text('Submitted: ${d['createdAtReadable'] ?? ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'confirm') {
                        await _updateStatus(context, docs[i].id, 'Confirmed');
                      } else if (v == 'reject') {
                        await _updateStatus(context, docs[i].id, 'Rejected');
                      } else if (v == 'delete') {
                        await FirebaseFirestore.instance.collection('payments').doc(docs[i].id).delete();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'confirm', child: Row(children: const [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Confirm')])),
                      PopupMenuItem(value: 'reject', child: Row(children: const [Icon(Icons.close, color: Colors.red), SizedBox(width: 8), Text('Reject')])),
                      PopupMenuItem(value: 'delete', child: Row(children: const [Icon(Icons.delete, color: Colors.grey), SizedBox(width: 8), Text('Delete')])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
