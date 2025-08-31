import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_aware_application/Screens/Login/login_screen.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_drawer_pages/gallery_page.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // Modern therapist color palette
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color accentBlue = Color(0xFF90CAF9);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF8FAF9);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = {};
  bool isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to sign out of your therapist account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildModernProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, lightBlue.withOpacity(0.9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with settings icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Therapist Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () =>
                          navigateTo(UpdateProfilePage(userData: userData)),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Avatar and Info
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Professional therapist badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'LICENSED THERAPIST',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Avatar with professional indicator
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: accentBlue,
                            child: Text(
                              (userData['firstName']?[0] ?? 'D').toUpperCase() +
                                  (userData['lastName']?[0] ?? 'R')
                                      .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Professional status indicator
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name and Title
                  Text(
                    'Dr. ${userData['firstName'] ?? 'Therapist'} ${userData['lastName'] ?? 'Name'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Specialization Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MENTAL HEALTH SPECIALIST',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Stats Cards
                  _buildQuickStatsRow(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Patients', '24', Icons.people_outline),
          _buildStatCard('Sessions', '156', Icons.psychology_outlined),
          _buildStatCard('Rating', '4.9', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<MenuItemData> items,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildModernMenuItem(
                item: item,
                isLast: index == items.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required MenuItemData item,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),

              const SizedBox(width: 16),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundGray,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildModernProfileHeader()),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundGray,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Patient Management Section
                    _buildMenuSection(
                      title: 'Patient Management',
                      items: [
                        MenuItemData(
                          icon: Icons.people_outline,
                          title: 'Patient List',
                          subtitle: 'Manage assigned patients',
                          iconColor: primaryBlue,
                          onTap: () =>
                              navigateTo(const TherapistUserListPage()),
                        ),
                        MenuItemData(
                          icon: Icons.book_online_outlined,
                          title: 'Appointments',
                          subtitle: 'Manage session bookings',
                          iconColor: Colors.orange,
                          onTap: () => navigateTo(const TherapistBookingPage()),
                        ),
                        MenuItemData(
                          icon: Icons.mood_outlined,
                          title: 'Mood Tracker',
                          subtitle: 'Monitor patient progress',
                          iconColor: Colors.purple,
                          onTap: () =>
                              navigateTo(const TherapistMoodTrackerPage()),
                        ),
                      ],
                    ),

                    // Clinical Tools Section
                    _buildMenuSection(
                      title: 'Clinical Tools',
                      items: [
                        MenuItemData(
                          icon: Icons.emergency_outlined,
                          title: 'Emergency Resources',
                          subtitle: 'Crisis intervention tools',
                          iconColor: Colors.red,
                          onTap: () =>
                              navigateTo(const TherapistEmergiesDashboard()),
                        ),
                        MenuItemData(
                          icon: Icons.star_outline,
                          title: 'Testimonials',
                          subtitle: 'Patient success stories',
                          iconColor: Colors.amber,
                          onTap: () =>
                              navigateTo(const TherapistPostTestimonyPage()),
                        ),
                        MenuItemData(
                          icon: Icons.photo_library_outlined,
                          title: 'Resource Gallery',
                          subtitle: 'Therapeutic materials',
                          iconColor: Colors.teal,
                          onTap: () => navigateTo(const GalleryPage()),
                        ),
                      ],
                    ),

                    // Communication Section
                    _buildMenuSection(
                      title: 'Communication',
                      items: [
                        MenuItemData(
                          icon: Icons.message_outlined,
                          title: 'Messages',
                          subtitle: 'Patient communications',
                          iconColor: Colors.blue,
                          onTap: () => navigateTo(const MessagesPage()),
                        ),
                        MenuItemData(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'System alerts and updates',
                          iconColor: Colors.indigo,
                          onTap: () => navigateTo(const NotificationsPage()),
                        ),
                        MenuItemData(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          subtitle: 'Patient and system feedback',
                          iconColor: Colors.green,
                          onTap: () => navigateTo(const TherapistDashboard()),
                        ),
                      ],
                    ),

                    // Business Management Section
                    _buildMenuSection(
                      title: 'Business Management',
                      items: [
                        MenuItemData(
                          icon: Icons.payment_outlined,
                          title: 'Transactions',
                          subtitle: 'Payment and billing records',
                          iconColor: Colors.green,
                          onTap: () =>
                              navigateTo(const AdminTransactionsPage()),
                        ),
                      ],
                    ),

                    // Account Settings Section
                    _buildMenuSection(
                      title: 'Account Settings',
                      items: [
                        MenuItemData(
                          icon: Icons.person_outline,
                          title: 'Update Profile',
                          subtitle: 'Edit professional information',
                          iconColor: primaryBlue,
                          onTap: () =>
                              navigateTo(UpdateProfilePage(userData: userData)),
                        ),
                        MenuItemData(
                          icon: Icons.logout_outlined,
                          title: 'Sign Out',
                          subtitle: 'Logout from therapist account',
                          iconColor: Colors.red,
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    required this.onTap,
  });
}
