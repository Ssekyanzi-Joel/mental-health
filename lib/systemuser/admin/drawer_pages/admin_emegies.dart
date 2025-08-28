import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mind_aware_application/constants.dart';

/// ----------------- Admin Dashboard -----------------
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _markResolved(String docId) async {
    await FirebaseFirestore.instance
        .collection("emergencies")
        .doc(docId)
        .update({"status": "Resolved"});
  }

  Future<void> _deleteEmergency(String docId) async {
    await FirebaseFirestore.instance
        .collection("emergencies")
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("emergencies")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No emergencies reported yet."),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(defaultPadding),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String docId = doc.id;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(data['title'] ?? "Unknown Emergency"),
                  subtitle: Text(
                      "${data['description'] ?? 'No description'}\nStatus: ${data['status'] ?? 'Pending'}\nReported at: ${data['timestamp']?.toDate()}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "Resolve") {
                        _markResolved(docId);
                      } else if (value == "Delete") {
                        _deleteEmergency(docId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "Resolve",
                        child: Text("Mark as Resolved"),
                      ),
                      const PopupMenuItem(
                        value: "Delete",
                        child: Text("Delete Emergency"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
