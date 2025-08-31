import 'package:flutter/material.dart';
import 'package:mind_aware_application/components/unified_bottom_shell.dart';
import 'package:mind_aware_application/systemuser/user/pages/booking_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/home_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/journaling_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/profile_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedBottomShell(
      pages: const [
        HomePage(),
        CommunityPage(),
        UserBookingPage(),
        JournalingPage(),
        ProfilePage(),
      ],
      navigationItems: const [
        NavigationItem(icon: Icons.home_rounded, label: 'Home'),
        NavigationItem(icon: Icons.groups_rounded, label: 'Community'),
        NavigationItem(icon: Icons.event_available_rounded, label: 'Booking'),
        NavigationItem(icon: Icons.menu_book_rounded, label: 'Journal'),
        NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
      ],
    );
  }
}
