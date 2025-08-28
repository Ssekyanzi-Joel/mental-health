import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:mind_aware_application/systemuser/user/pages/booking_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/home_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/journaling_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/profile_page.dart';
import 'package:mind_aware_application/systemuser/user/widgets/custom_appbar.dart';

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
      appBar: const CustomAppBar(title: 'Mind Aware', height: 50),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_index],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        elevation: 6,
        curveSize: 90,
        height: 62,
        backgroundColor: const Color.fromARGB(
          255,
          35,
          70,
          40,
        ), // slightly lighter green than page background
        color: const Color.fromARGB(
          255,
          180,
          220,
          190,
        ), // minty green for inactive icons
        activeColor: const Color.fromARGB(
          255,
          55,
          120,
          65,
        ), // leafy green for active icon
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.groups_rounded, title: 'Community'),
          TabItem(icon: Icons.event_available_rounded, title: 'Booking'),
          TabItem(icon: Icons.menu_book_rounded, title: 'Journal'),
          TabItem(icon: Icons.person_rounded, title: 'Profile'),
        ],
        initialActiveIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
