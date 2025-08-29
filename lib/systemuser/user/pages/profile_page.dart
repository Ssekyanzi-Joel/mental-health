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
  // Minimal color theme - green focused with neutrals
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color.fromARGB(255, 3, 104, 36);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color neutralGray = Color(0xFF757575);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  // Minimal gradient colors - green and neutral tones only
  static const List<Color> headerGradient = [
    Color.fromARGB(255, 6, 95, 2),
    Color.fromARGB(255, 18, 121, 49),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF757575),
    Color(0xFF9E9E9E),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF81C784),
    Color(0xFFA5D6A7),
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchUserData();
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
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Animated profile avatar with rainbow glow
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.4 * value),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primaryGreen.withOpacity(0.8),
                                lightGreen.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: darkGreen.withOpacity(0.1),
                              child: Text(
                                (userData['firstName']?[0] ?? 'U') +
                                    (userData['lastName']?[0] ?? ''),
                                style: TextStyle(
                                  fontSize: 42,
                                  color: darkGreen,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Animated name with gradient text
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                    ).createShader(bounds),
                    child: Text(
                      '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced info cards with colorful accents
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Email card with gradient border
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGreen, lightGreen],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryGreen, lightGreen],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    userData['email'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Phone card (if phone exists)
                        if (userData['phone'] != null &&
                            userData['phone'].toString().isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [neutralGray, darkGray],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(23),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [neutralGray, darkGray],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.phone_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      userData['phone'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    String? subtitle,
    int delay = 0,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors.first.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: gradientColors.first.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: gradientColors.first,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: headerGradient),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading your profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightBackground,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            // Account Settings Section
            _buildSectionHeader(
              "Account Settings",
              Icons.settings,
              primaryGradient,
            ),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: "Update Profile",
              subtitle: "Edit your personal information",
              gradientColors: primaryGradient,
              onTap: () => navigateTo(UpdateProfilePage(userData: userData)),
              delay: 100,
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "Manage your notification preferences",
              gradientColors: secondaryGradient,
              onTap: () => navigateTo(const NotificationsPage()),
              delay: 200,
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: "Payment Options",
              subtitle: "Manage billing and payments",
              gradientColors: accentGradient,
              onTap: () => navigateTo(const PaymentOptionsPage()),
              delay: 300,
            ),

            // Communication Section
            _buildSectionHeader(
              "Communication",
              Icons.message,
              secondaryGradient,
            ),
            _buildProfileOption(
              icon: Icons.message_outlined,
              title: "Messages",
              subtitle: "View your conversations",
              gradientColors: secondaryGradient,
              onTap: () => navigateTo(const MessagesPage()),
              delay: 400,
            ),
            _buildProfileOption(
              icon: Icons.feedback_outlined,
              title: "Feedback",
              subtitle: "Share your thoughts with us",
              gradientColors: accentGradient,
              onTap: () => navigateTo(const FeedbackPage()),
              delay: 500,
            ),

            // Support & Information Section
            _buildSectionHeader(
              "Support & Information",
              Icons.help_outline,
              primaryGradient,
            ),
            _buildProfileOption(
              icon: Icons.emergency_outlined,
              title: "Emergency Resources",
              subtitle: "Crisis support and hotlines",
              gradientColors: [Colors.red.shade400, Colors.red.shade600],
              onTap: () => navigateTo(const EmergenciesPage()),
              delay: 600,
            ),
            _buildProfileOption(
              icon: Icons.contact_support_outlined,
              title: "Help & Contact",
              subtitle: "Get support and contact us",
              gradientColors: primaryGradient,
              onTap: () => navigateTo(const HelpContactPage()),
              delay: 700,
            ),
            _buildProfileOption(
              icon: Icons.info_outline,
              title: "About Us",
              subtitle: "Learn more about Mind Aware",
              gradientColors: accentGradient,
              onTap: () => navigateTo(const AboutUsPage()),
              delay: 800,
            ),

            // Resources Section
            _buildSectionHeader(
              "Resources",
              Icons.library_books,
              accentGradient,
            ),
            _buildProfileOption(
              icon: Icons.article_outlined,
              title: "Articles",
              subtitle: "Mental health articles and tips",
              gradientColors: accentGradient,
              onTap: () => navigateTo(ArticlesPage()),
              delay: 900,
            ),
            _buildProfileOption(
              icon: Icons.photo_library_outlined,
              title: "Gallery",
              subtitle: "Inspirational images and content",
              gradientColors: primaryGradient,
              onTap: () => navigateTo(GalleryPage()),
              delay: 1000,
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              title: "Testimonials",
              subtitle: "Success stories from our community",
              gradientColors: secondaryGradient,
              onTap: () => navigateTo(const TestimoniesPage()),
              delay: 1100,
            ),

            // Account Actions Section
            _buildSectionHeader("Account", Icons.account_circle, [
              Colors.grey.shade600,
              Colors.grey.shade800,
            ]),
            _buildProfileOption(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of your account",
              gradientColors: [Colors.red.shade400, Colors.red.shade700],
              onTap: () => navigateTo(const LogoutPage()),
              delay: 1200,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
