import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_aware_application/components/unified_bottom_shell.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_profile_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_report_dashboard.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_eduction_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';

class TherapistBottom extends StatefulWidget {
  const TherapistBottom({super.key});

  @override
  State<TherapistBottom> createState() => _TherapistBottomState();
}

class _TherapistBottomState extends State<TherapistBottom> {
  String _therapistName = 'Therapist';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTherapistName();
  }

  Future<void> _fetchTherapistName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('therapists')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            _therapistName = doc.data()!['name'] ?? 'Therapist';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching therapist name: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _getPages() {
    if (_isLoading) {
      return [
        const Center(child: CircularProgressIndicator()),
        const Center(child: CircularProgressIndicator()),
        const Center(child: CircularProgressIndicator()),
        const Center(child: CircularProgressIndicator()),
        const Center(child: CircularProgressIndicator()),
      ];
    }

    return [
      TherapyPage(therapistName: _therapistName),
      const CommunityPage(),
      const TherapistBookingPage(),
      const TherapistReportDashboard(therapistId: '1'),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedBottomShell(
      pages: _getPages(),
      navigationItems: const [
        NavigationItem(icon: Icons.home_rounded, label: 'Home'),
        NavigationItem(icon: Icons.groups_rounded, label: 'Community'),
        NavigationItem(icon: Icons.event_available_rounded, label: 'Booking'),
        NavigationItem(icon: Icons.menu_book_rounded, label: 'Reports'),
        NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
      ],
    );
  }
}
