import 'package:flutter/material.dart';
import 'package:mind_aware_application/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergenciesPage extends StatelessWidget {
  const EmergenciesPage({super.key});

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildEmergencyCard(
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap,
      Color color = kPrimaryColor}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Emergency Contacts",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 15),
            _buildEmergencyCard(
              icon: Icons.call,
              title: "Call Helpline",
              description: "Direct call to trained mental health professionals.",
              onTap: () => _launchURL("tel:+256700000000"),
              color: Colors.red,
            ),
            _buildEmergencyCard(
              icon: Icons.message,
              title: "Send SMS",
              description: "Quickly send a text message for assistance.",
              onTap: () => _launchURL("sms:+256700000000?body=I need urgent help"),
              color: Colors.orange,
            ),
            _buildEmergencyCard(
              icon: Icons.chat,
              title: "WhatsApp",
              description: "Reach our support team on WhatsApp.",
              onTap: () => _launchURL("https://wa.me/256700000000?text=I need urgent help"),
              color: Colors.green,
            ),
            _buildEmergencyCard(
              icon: Icons.email,
              title: "Email Support",
              description: "Send an email and we will respond promptly.",
              onTap: () => _launchURL("mailto:support@mindaware.com?subject=Emergency"),
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Tips During Crisis",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              "1. Stay calm and take deep breaths.\n"
              "2. Reach out to a trusted friend or family member.\n"
              "3. Use our emergency contact methods above.\n"
              "4. If you feel unsafe, call local emergency services immediately.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
