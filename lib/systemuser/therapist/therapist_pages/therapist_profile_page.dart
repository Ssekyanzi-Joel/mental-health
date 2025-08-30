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
  // Redesigned color palette - more balanced and professional
  static const Color primaryBlue = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color lightBlue = Color.fromARGB(255, 7, 73, 45); // Lighter blue accent
  static const Color softGray = Color(0xFF7A8B99); // Muted gray-blue
  static const Color warmWhite = Color(0xFFFAFBFC); // Warm white background
  static const Color cardWhite = Color(0xFFFFFFFF); // Pure white for cards
  static const Color textDark = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color textLight = Color(0xFF5A6B7A); // Light text
  static const Color accentTeal = Color(0xFF4A9B8E); // Calming teal
  static const Color accentOrange = Color(0xFFE17B47); // Warm orange
  static const Color accentPurple = Color(0xFF8B7AB8); // Soft purple

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
          colors: [primaryBlue, lightBlue, softGray.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Professional therapist badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: cardWhite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cardWhite.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_outlined, color: cardWhite, size: 18),
                const SizedBox(width: 10),
                Text(
                  'LICENSED THERAPIST',
                  style: TextStyle(
                    color: cardWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Clean profile avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cardWhite.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: cardWhite,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: accentTeal,
                child: Text(
                  (userData['firstName']?[0] ?? 'T') +
                      (userData['lastName']?[0] ?? 'H'),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Professional name display
          Text(
            'Dr. ${userData['firstName'] ?? 'Therapist'} ${userData['lastName'] ?? 'User'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 16),

          // Contact information cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Email card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cardWhite.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cardWhite.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          userData['email'] ?? 'therapist@mindaware.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone card (if exists)
                if (userData['phone'] != null &&
                    userData['phone'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cardWhite.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cardWhite.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.phone_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            userData['phone'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
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

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
              letterSpacing: 0.2,
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: softGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: softGray,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: warmWhite,
        body: Center(
          child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 3),
        ),
      );
    }

    return Scaffold(
      backgroundColor: warmWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            // Account Settings Section
            _buildSectionHeader("Account Management", Icons.settings_outlined),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: "Update Profile",
              subtitle: "Edit therapist profile information",
              iconColor: primaryBlue,
              onTap: () => navigateTo(UpdateProfilePage(userData: userData)),
            ),
            _buildProfileOption(
              icon: Icons.people_outline,
              title: "Users",
              subtitle: "Manage assigned patients",
              iconColor: accentTeal,
              onTap: () => navigateTo(const TherapistUserListPage()),
            ),

            // Patient Care Section
            _buildSectionHeader(
              "Patient Care",
              Icons.health_and_safety_outlined,
            ),
            _buildProfileOption(
              icon: Icons.emergency_outlined,
              title: "Emergency Resources",
              subtitle: "Crisis intervention and support",
              iconColor: const Color(0xFFE74C3C),
              onTap: () => navigateTo(const TherapistEmergiesDashboard()),
            ),
            _buildProfileOption(
              icon: Icons.mood_outlined,
              title: "Mood Tracker",
              subtitle: "Monitor patient mood patterns",
              iconColor: accentPurple,
              onTap: () => navigateTo(const TherapistMoodTrackerPage()),
            ),
            _buildProfileOption(
              icon: Icons.book_online_outlined,
              title: "Bookings",
              subtitle: "Manage appointment schedule",
              iconColor: accentOrange,
              onTap: () => navigateTo(const TherapistBookingPage()),
            ),

            // Content Management Section
            _buildSectionHeader(
              "Content & Resources",
              Icons.library_books_outlined,
            ),
            _buildProfileOption(
              icon: Icons.photo_library_outlined,
              title: "Gallery",
              subtitle: "Manage therapeutic resources",
              iconColor: lightBlue,
              onTap: () => navigateTo(const GalleryPage()),
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              title: "Testimonials",
              subtitle: "Patient success stories",
              iconColor: const Color(0xFFF39C12),
              onTap: () => navigateTo(const TherapistPostTestimonyPage()),
            ),

            // Communication Section
            _buildSectionHeader("Communication", Icons.chat_bubble_outline),
            _buildProfileOption(
              icon: Icons.message_outlined,
              title: "Messages",
              subtitle: "Patient communications",
              iconColor: accentTeal,
              onTap: () => navigateTo(const MessagesPage()),
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "System alerts and updates",
              iconColor: accentPurple,
              onTap: () => navigateTo(const NotificationsPage()),
            ),
            _buildProfileOption(
              icon: Icons.feedback_outlined,
              title: "Feedback",
              subtitle: "Patient and system feedback",
              iconColor: accentOrange,
              onTap: () => navigateTo(const TherapistDashboard()),
            ),

            // Business Section
            _buildSectionHeader(
              "Business Management",
              Icons.business_center_outlined,
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: "Transactions",
              subtitle: "Payment and billing records",
              iconColor: const Color(0xFF27AE60),
              onTap: () => navigateTo(const AdminTransactionsPage()),
            ),

            // Account Actions
            _buildSectionHeader(
              "Account Actions",
              Icons.account_circle_outlined,
            ),
            _buildProfileOption(
              icon: Icons.logout_outlined,
              title: "Logout",
              subtitle: "Sign out of therapist account",
              iconColor: const Color(0xFFE74C3C),
              onTap: () => navigateTo(const LogoutPage()),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
