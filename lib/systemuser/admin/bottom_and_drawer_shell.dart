import 'package:flutter/material.dart';
import 'package:mind_aware_application/components/unified_bottom_shell.dart';
import 'package:mind_aware_application/systemuser/admin/drawer_pages/admin_education_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/admin_profile_page.dart';
import 'package:mind_aware_application/systemuser/admin/pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/admin/pages/user_management_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';

class Admindasborad extends StatelessWidget {
  const Admindasborad({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedBottomShell(
      pages: const [
        AdminTherapyPage(),
        CommunityPage(),
        BookingPage(),
        UserManagementPage(),
        ProfilePage(),
      ],
      navigationItems: const [
        NavigationItem(icon: Icons.home_rounded, label: 'Home'),
        NavigationItem(icon: Icons.groups_rounded, label: 'Community'),
        NavigationItem(icon: Icons.event_available_rounded, label: 'Booking'),
        NavigationItem(icon: Icons.people, label: 'All Users'),
        NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
      ],
    );
  }
}
