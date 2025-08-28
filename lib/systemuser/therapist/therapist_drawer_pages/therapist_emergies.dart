import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mind_aware_application/constants.dart';

/// ----------------- Therapist Dashboard -----------------
class TherapistEmergiesDashboard extends StatelessWidget {
  const TherapistEmergiesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist Dashboard"),
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
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(data['title'] ?? "Unknown Emergency"),
                  subtitle: Text(
                      "${data['description'] ?? 'No description'}\nReported at: ${data['timestamp']?.toDate()}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

