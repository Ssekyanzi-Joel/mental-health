import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TherapistDetailPage extends StatelessWidget {
  final String therapistId;
  const TherapistDetailPage({super.key, required this.therapistId});

  @override
  Widget build(BuildContext context) {
    final therapistRef =
        FirebaseFirestore.instance.collection("therapists").doc(therapistId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist Details"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: therapistRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${data['firstName']} ${data['lastName']}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Email: ${data['email']}"),
                Text("Phone: ${data['phone']}"),
                Text("Gender: ${data['gender']}"),
                Text("City: ${data['city']}, Country: ${data['country']}"),
                const Divider(height: 24),
                Text("Qualification: ${data['qualification']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Specialization: ${data['specialization']}"),
                Text("Availability: ${data['availability']}"),
                Text("Experience: ${data['experience']} years"),
                Text("Bio: ${data['bio']}"),
                const Divider(height: 24),
                Text("Documents / Certificates",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['documents'] as List<dynamic>).map((doc) {
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(doc['name']),
                    subtitle: Text(doc['type']),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () async {
                        final url = doc['url'];
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
