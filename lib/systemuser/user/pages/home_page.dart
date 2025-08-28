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
  // Your specified green theme colors
  static const Color primaryBackground = Color.fromRGBO(15, 40, 20, 1);
  static const Color mainThemeColor = Color.fromRGBO(25, 53, 30, 1);
  static const Color cardContainer = Color.fromRGBO(35, 70, 40, 1);
  static const Color accentGreen = Color.fromRGBO(76, 175, 80, 1);
  static const Color lightGreen = Color.fromRGBO(129, 199, 132, 1);
  static const Color creamWhite = Color(0xFFF7F5F3);
  static const Color lightCream = Color(0xFFE8F5E8);

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

  // Bigger hero header with more background coverage
  Widget _buildHeroHeader() {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.65, // Increased from 0.5 to 0.65
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/sara5.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: mainThemeColor.withOpacity(0.65),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40), // Top padding for status bar
              // User info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      isLoading
                          ? 'U'
                          : '${userData['firstName']?[0] ?? 'U'}${userData['lastName']?[0] ?? ''}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isLoading
                              ? 'Loading...'
                              : '${userData['firstName'] ?? 'User'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Centered main message
              Column(
                children: [
                  const Text(
                    "Your Mental Health Matters 💚",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "How are you feeling today?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  "AI Assistant",
                  "Chat with our AI therapist",
                  Icons.psychology,
                  accentGreen,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  "Mood Check",
                  "Track your emotions",
                  Icons.mood,
                  cardContainer,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodTrackerPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Expanded daily tips section with more tips
  Widget _buildDailyTips() {
    final tips = [
      {
        "title": "Breathing Exercise",
        "tip": "Take 5 deep breaths when feeling overwhelmed",
        "icon": Icons.air,
      },
      {
        "title": "Gratitude Practice",
        "tip": "List 3 things you're thankful for today",
        "icon": Icons.favorite,
      },
      {
        "title": "Movement Therapy",
        "tip": "Take a 10-minute walk to clear your mind",
        "icon": Icons.directions_walk,
      },
      {
        "title": "Social Connection",
        "tip": "Reach out to a friend or loved one today",
        "icon": Icons.people,
      },
      {
        "title": "Mindfulness",
        "tip": "Practice mindfulness for just 2 minutes",
        "icon": Icons.self_improvement,
      },
      {
        "title": "Hydration",
        "tip": "Drink a glass of water mindfully",
        "icon": Icons.local_drink,
      },
      {
        "title": "Nature Time",
        "tip": "Spend 5 minutes outside in fresh air",
        "icon": Icons.eco,
      },
      {
        "title": "Self-Compassion",
        "tip": "Speak to yourself as kindly as you would a friend",
        "icon": Icons.psychology,
      },
      {
        "title": "Digital Detox",
        "tip": "Take a 30-minute break from screens",
        "icon": Icons.phone_locked,
      },
      {
        "title": "Creative Expression",
        "tip": "Draw, write, or create something for 10 minutes",
        "icon": Icons.brush,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily Mental Health Tips",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 16),
          // Display 3 random tips
          ...List.generate(3, (index) {
            final randomTip = tips[(DateTime.now().day + index) % tips.length];
            return _buildTipCard(
              randomTip['title'] as String,
              randomTip['tip'] as String,
              randomTip['icon'] as IconData,
              index,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String tip, IconData icon, int index) {
    // Alternate colors for variety
    final colors = [mainThemeColor, cardContainer, accentGreen];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightCream, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip,
            style: TextStyle(
              fontSize: 16,
              color: color.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "Please sign in to continue",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamWhite,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(), // Bigger background coverage
                const SizedBox(height: 20),
                _buildQuickActions(), // Maintained as requested
                const SizedBox(height: 20),
                _buildDailyTips(), // Expanded daily tips section
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        ),
        backgroundColor: mainThemeColor,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text(
          "AI Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }
}
