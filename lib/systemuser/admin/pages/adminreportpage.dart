import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  void updateStatus(String docId, String status) {
    FirebaseFirestore.instance.collection("reports").doc(docId).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Reports")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Report for ${report['userName']}"),
                  subtitle: Text("Status: ${report['status']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => updateStatus(report.id, "Approved")),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => updateStatus(report.id, "Rejected")),
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
