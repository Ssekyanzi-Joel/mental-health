import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/chat_screen.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/mood_tacker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Headspace-inspired calming color palette
  static const Color primaryBackground = Color(0xFFF8F9FA);
  static const Color mainThemeColor = Color(0xFF2D5A3D);
  static const Color accentGreen = Color(0xFF6BCF7F);
  static const Color lightGreen = Color(0xFF9CDBA6);
  static const Color creamWhite = Color(0xFFFFFDF7);
  static const Color softOrange = Color(0xFFFFB347);
  static const Color softBlue = Color(0xFF87CEEB);
  static const Color softPurple = Color(0xFFB19CD9);

  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
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
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error fetching user data: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // Clean header section integrated into body
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [creamWhite, primaryBackground],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User greeting section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      color: mainThemeColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoading
                        ? 'Loading...'
                        : '${userData['firstName'] ?? 'User'}',
                    style: const TextStyle(
                      color: mainThemeColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Profile and notifications
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: mainThemeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: accentGreen.withOpacity(0.2),
                  child: Text(
                    isLoading
                        ? 'U'
                        : '${userData['firstName']?[0] ?? 'U'}${userData['lastName']?[0] ?? ''}',
                    style: TextStyle(
                      fontSize: 16,
                      color: mainThemeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mindful check-in hero section
  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentGreen, lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("🌱", style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          const Text(
            "How are you feeling?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Take a moment to check in with yourself",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Focus",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 20),
          // Grid of wellness activities
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildWellnessCard(
                "Mindful Chat",
                "AI Companion",
                "🤖",
                softBlue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                ),
              ),
              _buildWellnessCard(
                "Mood Check",
                "Track feelings",
                "😊",
                softOrange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedMoodTrackerPage(),
                  ),
                ),
              ),
              _buildWellnessCard(
                "Breathe",
                "5 min session",
                "🫁",
                accentGreen,
                () => _showBreathingExercise(),
              ),
              _buildWellnessCard(
                "Reflect",
                "Daily journal",
                "📝",
                softPurple,
                () => _showJournalPrompt(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessCard(
    String title,
    String subtitle,
    String emoji,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: mainThemeColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: mainThemeColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Breathing Exercise",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: mainThemeColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Follow the circle to breathe mindfully",
                style: TextStyle(
                  color: mainThemeColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [accentGreen, lightGreen]),
                ),
                child: const Center(
                  child: Text("🫁", style: TextStyle(fontSize: 48)),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Start Session",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJournalPrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Daily Reflection",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: mainThemeColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "What are three things you're grateful for today?",
                style: TextStyle(
                  color: mainThemeColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const TextField(
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Write your thoughts here...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: softPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save Reflection",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mindful moments section with gentle wisdom
  Widget _buildMindfulMoments() {
    final moments = [
      {
        "title": "Mindful Breathing",
        "tip":
            "Notice your breath. Each inhale brings calm, each exhale releases tension.",
        "emoji": "🌬️",
        "color": softBlue,
      },
      {
        "title": "Gratitude Pause",
        "tip":
            "Name three small things that brought you joy today, however tiny.",
        "emoji": "🙏",
        "color": softOrange,
      },
      {
        "title": "Body Awareness",
        "tip": "Gently scan from your toes to your head. What do you notice?",
        "emoji": "🧘",
        "color": softPurple,
      },
      {
        "title": "Present Moment",
        "tip":
            "Right now, you are exactly where you need to be. That's enough.",
        "emoji": "⭐",
        "color": accentGreen,
      },
      {
        "title": "Self Compassion",
        "tip":
            "Speak to yourself with the same kindness you'd show a dear friend.",
        "emoji": "💚",
        "color": lightGreen,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mindful Moments",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 20),
          // Display 2 rotating mindful moments
          ...List.generate(2, (index) {
            final moment =
                moments[(DateTime.now().day + index) % moments.length];
            return _buildMindfulCard(
              moment['title'] as String,
              moment['tip'] as String,
              moment['emoji'] as String,
              moment['color'] as Color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMindfulCard(
    String title,
    String tip,
    String emoji,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: mainThemeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip,
            style: TextStyle(
              fontSize: 16,
              color: mainThemeColor.withOpacity(0.7),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: primaryBackground,
        body: Center(
          child: Text(
            "Please sign in to continue",
            style: TextStyle(fontSize: 18, color: mainThemeColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                _buildHeroSection(),
                _buildQuickActions(),
                const SizedBox(height: 32),
                _buildMindfulMoments(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        ),
        backgroundColor: accentGreen,
        elevation: 8,
        child: const Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
