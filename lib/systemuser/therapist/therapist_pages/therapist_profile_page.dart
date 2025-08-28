import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/gallery_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/logout_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therapist_emergies.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therapist_feedback.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therapist_mood_tracker_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therapist_testimonies_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therapistusermanagementpage.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therpist_transactions_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/therpist_update_user.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/messages_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Modern theme colors - consistent with user profile
  static const Color deepGreen = Color.fromARGB(255, 25, 53, 30);
  static const Color sectionLightGreen = Color.fromARGB(255, 180, 220, 190);
  static const Color listTileCream = Color.fromARGB(255, 245, 245, 220);
  static const Color accentGreen = Color.fromARGB(255, 76, 175, 80);
  static const Color therapistBlue = Color.fromARGB(255, 33, 150, 243);
  static const Color therapistOrange = Color.fromARGB(255, 255, 152, 0);

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error fetching user data: $e");
    }
  }

  void navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(25, 53, 30, 1),
            const Color.fromRGBO(46, 125, 50, 1),
            const Color.fromRGBO(76, 175, 80, 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(25, 53, 30, 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Therapist badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, color: Colors.blue[300], size: 16),
                const SizedBox(width: 8),
                Text(
                  'THERAPIST',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Modern profile avatar with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 57,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: Text(
                    (userData['firstName']?[0] ?? 'T') +
                        (userData['lastName']?[0] ?? 'H'),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Modern name display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Dr. ${userData['firstName'] ?? 'Therapist'} ${userData['lastName'] ?? 'User'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Modern info cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Email card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              userData['email'] ?? 'therapist@mindaware.com',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Phone card (if phone exists)
                if (userData['phone'] != null &&
                    userData['phone'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            userData['phone'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: sectionLightGreen, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: sectionLightGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: listTileCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: deepGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: deepGreen,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: deepGreen.withOpacity(0.6),
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: deepGreen.withOpacity(0.6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: deepGreen,
        body: Center(child: CircularProgressIndicator(color: accentGreen)),
      );
    }

    return Scaffold(
      backgroundColor: deepGreen,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            // Account Settings Section
            _buildSectionHeader("Account Management", Icons.settings),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: "Update Profile",
              subtitle: "Edit therapist profile information",
              iconColor: accentGreen,
              onTap: () => navigateTo(UpdateProfilePage(userData: userData)),
            ),
            _buildProfileOption(
              icon: Icons.people_outline,
              title: "Users",
              subtitle: "Manage assigned patients",
              iconColor: therapistBlue,
              onTap: () => navigateTo(const TherapistUserListPage()),
            ),

            // Patient Care Section
            _buildSectionHeader("Patient Care", Icons.health_and_safety),
            _buildProfileOption(
              icon: Icons.emergency_outlined,
              title: "Emergency Resources",
              subtitle: "Crisis intervention and support",
              iconColor: Colors.redAccent,
              onTap: () => navigateTo(const TherapistEmergiesDashboard()),
            ),
            _buildProfileOption(
              icon: Icons.mood_outlined,
              title: "Mood Tracker",
              subtitle: "Monitor patient mood patterns",
              iconColor: accentGreen,
              onTap: () => navigateTo(const TherapistMoodTrackerPage()),
            ),
            _buildProfileOption(
              icon: Icons.book_online_outlined,
              title: "Bookings",
              subtitle: "Manage appointment schedule",
              iconColor: therapistOrange,
              onTap: () => navigateTo(const TherapistBookingPage()),
            ),

            // Content Management Section
            _buildSectionHeader("Content & Resources", Icons.content_paste),
            _buildProfileOption(
              icon: Icons.photo_library_outlined,
              title: "Gallery",
              subtitle: "Manage therapeutic resources",
              iconColor: therapistBlue,
              onTap: () => navigateTo(const GalleryPage()),
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              title: "Testimonials",
              subtitle: "Patient success stories",
              iconColor: Colors.amber,
              onTap: () => navigateTo(const TherapistPostTestimonyPage()),
            ),

            // Communication Section
            _buildSectionHeader("Communication", Icons.message),
            _buildProfileOption(
              icon: Icons.message_outlined,
              title: "Messages",
              subtitle: "Patient communications",
              iconColor: therapistOrange,
              onTap: () => navigateTo(const MessagesPage()),
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "System alerts and updates",
              iconColor: therapistBlue,
              onTap: () => navigateTo(const NotificationsPage()),
            ),
            _buildProfileOption(
              icon: Icons.feedback_outlined,
              title: "Feedback",
              subtitle: "Patient and system feedback",
              iconColor: therapistOrange,
              onTap: () => navigateTo(const TherapistDashboard()),
            ),

            // Business Section
            _buildSectionHeader("Business Management", Icons.business),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: "Transactions",
              subtitle: "Payment and billing records",
              iconColor: Colors.amber,
              onTap: () => navigateTo(const AdminTransactionsPage()),
            ),

            // Account Actions
            _buildSectionHeader("Account Actions", Icons.account_circle),
            _buildProfileOption(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of therapist account",
              iconColor: Colors.redAccent,
              onTap: () => navigateTo(const LogoutPage()),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
