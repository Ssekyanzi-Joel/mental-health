import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:mind_aware_application/systemuser/user/pages/booking_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/home_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/journaling_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    CommunityPage(),
    UserBookingPage(),
    JournalingPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_index],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2E7D32), // Deep forest green
              const Color(0xFF388E3C), // Medium forest green
              const Color(0xFF43A047), // Vibrant green
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade700.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, -4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ConvexAppBar(
          style: TabStyle.react,
          elevation:
              0, // Remove default elevation since we're using custom shadow
          curveSize: 95,
          height: 65,
          backgroundColor:
              Colors.transparent, // Make transparent to show gradient
          color: const Color(0xFFE8F5E8), // Soft mint for inactive icons
          activeColor: const Color(0xFFFFFFFF), // Pure white for active icon
          items: [
            TabItem(
              icon: _buildAnimatedIcon(Icons.home_rounded, 0),
              title: 'Home',
            ),
            TabItem(
              icon: _buildAnimatedIcon(Icons.groups_rounded, 1),
              title: 'Community',
            ),
            TabItem(
              icon: _buildAnimatedIcon(Icons.event_available_rounded, 2),
              title: 'Booking',
            ),
            TabItem(
              icon: _buildAnimatedIcon(Icons.menu_book_rounded, 3),
              title: 'Journal',
            ),
            TabItem(
              icon: _buildAnimatedIcon(Icons.person_rounded, 4),
              title: 'Profile',
            ),
          ],
          initialActiveIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int tabIndex) {
    final isActive = _index == tabIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isActive ? 8.0 : 4.0),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withOpacity(0.3),
                width: 1.5,
              ),
            )
          : null,
      child: Icon(
        icon,
        size: isActive ? 26 : 24,
        color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFFE8F5E8),
      ),
    );
  }
}
