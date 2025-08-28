import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_aware_application/systemuser/admin/pages/therapist_detail_page.dart';



class AdminTherapistDashboard extends StatefulWidget {
  const AdminTherapistDashboard({super.key});

  @override
  State<AdminTherapistDashboard> createState() =>
      _AdminTherapistDashboardState();
}

class _AdminTherapistDashboardState extends State<AdminTherapistDashboard> {
  final CollectionReference therapistsRef =
      FirebaseFirestore.instance.collection("therapists");

  /// Approve or reject therapist
  Future<void> updateStatus(String therapistId, String status) async {
    await therapistsRef.doc(therapistId).update({"status": status});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Therapist status updated to $status")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist Management"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: therapistsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final therapists = snapshot.data!.docs;

          if (therapists.isEmpty) {
            return const Center(child: Text("No therapists found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: therapists.length,
            itemBuilder: (context, index) {
              final therapist = therapists[index];
              final data = therapist.data() as Map<String, dynamic>;
              final status = data['status'] ?? "pending";

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade200,
                    child: Text(
                      data['firstName'][0] + data['lastName'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text("${data['firstName']} ${data['lastName']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${data['email']}"),
                      Text("Phone: ${data['phone']}"),
                      Text("City: ${data['city']}, Country: ${data['country']}"),
                      Text("Status: $status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == "approved"
                                ? Colors.green
                                : status == "rejected"
                                    ? Colors.red
                                    : Colors.orange,
                          )),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Approve",
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: status == "approved"
                            ? null
                            : () => updateStatus(therapist.id, "approved"),
                      ),
                      IconButton(
                        tooltip: "Reject",
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: status == "rejected"
                            ? null
                            : () => updateStatus(therapist.id, "rejected"),
                      ),
                      IconButton(
                        tooltip: "View Details",
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TherapistDetailPage(
                                  therapistId: therapist.id),
                            ),
                          );
                        },
                      ),
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
