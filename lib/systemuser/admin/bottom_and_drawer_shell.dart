import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/admin_education_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/admin_profile_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/admin/pages/user_management_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';
import 'package:mind_aware_application/systemuser/user/widgets/custom_appbar.dart';

class Admindasborad extends StatefulWidget {
  const Admindasborad({super.key});

  @override
  State<Admindasborad> createState() => _AdmindasboradState();
}

class _AdmindasboradState extends State<Admindasborad> {
  int _index = 0;

  final _pages = const [
    AdminTherapyPage(),
    CommunityPage(),
    BookingPage(),
    UserManagementPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 240, 238), // deep green page background
      // appBar: const CustomAppBar(title: 'Admin Dashboard', height: 50),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_index],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        elevation: 6,
        curveSize: 90,
        height: 62,
        backgroundColor: const Color.fromARGB(255, 25, 53, 30), // medium green
        color: const Color.fromARGB(
          255,
          180,
          220,
          190,
        ), // inactive icons (mint)
        activeColor: const Color.fromARGB(
          255,
          76,
          175,
          80,
        ), // active leafy green
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.groups_rounded, title: 'Community'),
          TabItem(icon: Icons.event_available_rounded, title: 'Booking'),
          TabItem(icon: Icons.people, title: 'All Users'),
          TabItem(icon: Icons.person_rounded, title: 'Profile'),
        ],
        initialActiveIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
