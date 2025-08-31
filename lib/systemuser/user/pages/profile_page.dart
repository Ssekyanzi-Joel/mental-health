import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/about_us_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/articles_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/emergencies_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/feedback_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/gallery_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/help_contact_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/logout_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/messages_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/notifications_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/payment_options_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/testimonies_page.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/update_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // Modern color palette inspired by admin design
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF1B5E20);
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

  Widget _buildModernProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, lightGreen.withOpacity(0.9)],
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
                    'My Profile',
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
                  // Avatar with wellness indicator
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
                            backgroundColor: accentGreen,
                            child: Text(
                              (userData['firstName']?[0] ?? 'U').toUpperCase() +
                                  (userData['lastName']?[0] ?? 'S')
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
                      // Wellness status indicator
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
                            Icons.favorite,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name and Role
                  Text(
                    '${userData['firstName'] ?? 'User'} ${userData['lastName'] ?? 'Name'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User Badge
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
                        const Icon(Icons.person, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'MEMBER',
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
          _buildStatCard('Sessions', '12', Icons.psychology_outlined),
          _buildStatCard('Days', '45', Icons.calendar_today_outlined),
          _buildStatCard('Progress', '78%', Icons.trending_up_outlined),
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
                  color: darkGreen,
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
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
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

                    // Account Settings Section
                    _buildMenuSection(
                      title: 'Account Settings',
                      items: [
                        MenuItemData(
                          icon: Icons.person_outline,
                          title: 'Update Profile',
                          subtitle: 'Edit your personal information',
                          iconColor: primaryGreen,
                          onTap: () =>
                              navigateTo(UpdateProfilePage(userData: userData)),
                        ),
                        MenuItemData(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          iconColor: Colors.blue,
                          onTap: () => navigateTo(const NotificationsPage()),
                        ),
                        MenuItemData(
                          icon: Icons.payment_outlined,
                          title: 'Payment Options',
                          subtitle: 'Manage billing and payments',
                          iconColor: Colors.green,
                          onTap: () => navigateTo(const PaymentOptionsPage()),
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
                          subtitle: 'View your conversations',
                          iconColor: Colors.blue,
                          onTap: () => navigateTo(const MessagesPage()),
                        ),
                        MenuItemData(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          subtitle: 'Share your thoughts with us',
                          iconColor: Colors.orange,
                          onTap: () => navigateTo(const FeedbackPage()),
                        ),
                      ],
                    ),

                    // Wellness & Support Section
                    _buildMenuSection(
                      title: 'Wellness & Support',
                      items: [
                        MenuItemData(
                          icon: Icons.emergency_outlined,
                          title: 'Emergency Resources',
                          subtitle: 'Crisis support and hotlines',
                          iconColor: Colors.red,
                          onTap: () => navigateTo(const EmergenciesPage()),
                        ),
                        MenuItemData(
                          icon: Icons.contact_support_outlined,
                          title: 'Help & Contact',
                          subtitle: 'Get support and contact us',
                          iconColor: primaryGreen,
                          onTap: () => navigateTo(const HelpContactPage()),
                        ),
                        MenuItemData(
                          icon: Icons.info_outline,
                          title: 'About Us',
                          subtitle: 'Learn more about Mind Aware',
                          iconColor: Colors.purple,
                          onTap: () => navigateTo(const AboutUsPage()),
                        ),
                      ],
                    ),

                    // Resources Section
                    _buildMenuSection(
                      title: 'Resources',
                      items: [
                        MenuItemData(
                          icon: Icons.article_outlined,
                          title: 'Articles',
                          subtitle: 'Mental health articles and tips',
                          iconColor: Colors.teal,
                          onTap: () => navigateTo(ArticlesPage()),
                        ),
                        MenuItemData(
                          icon: Icons.photo_library_outlined,
                          title: 'Gallery',
                          subtitle: 'Inspirational images and content',
                          iconColor: Colors.indigo,
                          onTap: () => navigateTo(GalleryPage()),
                        ),
                        MenuItemData(
                          icon: Icons.star_outline,
                          title: 'Testimonials',
                          subtitle: 'Success stories from our community',
                          iconColor: Colors.amber,
                          onTap: () => navigateTo(const TestimoniesPage()),
                        ),
                      ],
                    ),

                    // Account Actions Section
                    _buildMenuSection(
                      title: 'Account Actions',
                      items: [
                        MenuItemData(
                          icon: Icons.logout_outlined,
                          title: 'Sign Out',
                          subtitle: 'Logout from your account',
                          iconColor: Colors.red,
                          onTap: () => navigateTo(const LogoutPage()),
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
