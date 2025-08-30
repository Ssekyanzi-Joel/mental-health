import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/admin_emegies.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/admin_feedback.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/admin_testimonies.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/logout_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/Admin_Latest_Users_Page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/Therapist_Management_Page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/admin_transactions_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/admin_update_user.dart';
import 'package:mind_aware_application/systemuser/admin/pages/adminreportpage.dart';
import 'package:mind_aware_application/systemuser/admin/pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/admin/pages/gallery_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/user_management_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/messages_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // Consistent color scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color surfaceGreen = Color(0xFFF1F8E9);

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = {};
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        gradient: const LinearGradient(
          colors: [primaryGreen, lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  userData['role']?.toString().toUpperCase() ?? 'ADMIN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Profile avatar
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
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                (userData['firstName']?[0] ?? 'A').toUpperCase() +
                    (userData['lastName']?[0] ?? 'D').toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User name
          Text(
            '${userData['firstName'] ?? 'Admin'} ${userData['lastName'] ?? 'User'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Contact info cards
          if (userData['email'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userData['email'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (userData['phone'] != null &&
              userData['phone'].toString().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userData['phone'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: surfaceGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGreen,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 14,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            // Account Settings Section
            _buildSectionHeader("Account Settings", Icons.settings),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: "Update Profile",
              subtitle: "Edit profile information",
              iconColor: primaryGreen,
              onTap: () => navigateTo(UpdateProfilePage(userData: userData)),
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              iconColor: Colors.blue,
              onTap: () => navigateTo(const NotificationsPage()),
            ),

            // Management Section
            _buildSectionHeader(
              "User & System Management",
              Icons.manage_accounts,
            ),
            _buildProfileOption(
              icon: Icons.people_outline,
              title: "User Management",
              subtitle: "Manage registered users",
              iconColor: Colors.blue,
              onTap: () => navigateTo(const UserManagementPage()),
            ),
            _buildProfileOption(
              icon: Icons.psychology_outlined,
              title: "Therapist Management",
              subtitle: "Manage therapist accounts",
              iconColor: Colors.blue,
              onTap: () => navigateTo(const AdminTherapistDashboard()),
            ),
            _buildProfileOption(
              icon: Icons.person_add_outlined,
              title: "Latest Users",
              subtitle: "View recently registered users",
              iconColor: Colors.orange,
              onTap: () => navigateTo(const AdminLatestUsersPage()),
            ),

            // Operations Section
            _buildSectionHeader("Operations & Analytics", Icons.analytics),
            _buildProfileOption(
              icon: Icons.assessment_outlined,
              title: "Reports",
              subtitle: "View system analytics and reports",
              iconColor: Colors.blue,
              onTap: () => navigateTo(const AdminReportsPage()),
            ),
            _buildProfileOption(
              icon: Icons.book_online_outlined,
              title: "Bookings",
              subtitle: "Manage appointment bookings",
              iconColor: Colors.orange,
              onTap: () => navigateTo(const BookingPage()),
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: "Transactions",
              subtitle: "Monitor payment transactions",
              iconColor: Colors.orange,
              onTap: () => navigateTo(const AdminTransactionsPage()),
            ),

            // Content Management Section
            _buildSectionHeader("Content Management", Icons.content_paste),
            _buildProfileOption(
              icon: Icons.photo_library_outlined,
              title: "Gallery",
              subtitle: "Manage image galleries",
              iconColor: accentGreen,
              onTap: () => navigateTo(const GalleryPage()),
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              title: "Testimonials",
              subtitle: "Manage user testimonials",
              iconColor: Colors.amber,
              onTap: () => navigateTo(const AdminPostTestimonyPage()),
            ),

            // Communication Section
            _buildSectionHeader("Communication", Icons.message),
            _buildProfileOption(
              icon: Icons.message_outlined,
              title: "Messages",
              subtitle: "View user messages",
              iconColor: Colors.orange,
              onTap: () => navigateTo(const MessagesPage()),
            ),
            _buildProfileOption(
              icon: Icons.feedback_outlined,
              title: "Feedback",
              subtitle: "Review user feedback",
              iconColor: Colors.orange,
              onTap: () => navigateTo(const TherapistDashboard()),
            ),

            // Emergency & Support Section
            _buildSectionHeader("Emergency & Support", Icons.emergency),
            _buildProfileOption(
              icon: Icons.emergency_outlined,
              title: "Emergency Resources",
              subtitle: "Manage crisis support resources",
              iconColor: Colors.red,
              onTap: () => navigateTo(const AdminDashboard()),
            ),

            // Account Actions Section
            _buildSectionHeader("Account Actions", Icons.account_circle),
            _buildProfileOption(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of account",
              iconColor: Colors.red,
              onTap: () => navigateTo(const LogoutPage()),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
