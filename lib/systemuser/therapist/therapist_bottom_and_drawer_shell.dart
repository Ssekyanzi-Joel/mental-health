import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_profile_page.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_report_dashboard.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/approve_booking.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_eduction_page.dart';
import 'package:mind_aware_application/systemuser/user/pages/community_page.dart';
import 'package:mind_aware_application/systemuser/user/widgets/custom_appbar.dart';

class TherapistBottom extends StatefulWidget {
  const TherapistBottom({super.key});

  @override
  State<TherapistBottom> createState() => _TherapistBottomState();
}

class _TherapistBottomState extends State<TherapistBottom> {
  int _index = 0;
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
      print('Error fetching therapist name: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getPage(int index) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (index) {
      case 0:
        return TherapyPage(therapistName: _therapistName);
      case 1:
        return const CommunityPage();
      case 2:
        return const TherapistBookingPage();
      case 3:
        return const TherapistReportDashboard(therapistId: '1');
      case 4:
        return const ProfilePage();
      default:
        return TherapyPage(therapistName: _therapistName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 40, 20),
     // appBar: const CustomAppBar(title: 'Mind Aware - Therapist', height: 50),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _getPage(_index),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        elevation: 6,
        curveSize: 90,
        height: 62,
        backgroundColor: const Color.fromARGB(255, 25, 53, 30),
        color: const Color.fromARGB(255, 180, 220, 190),
        activeColor: const Color.fromARGB(255, 76, 175, 80),
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.groups_rounded, title: 'Community'),
          TabItem(icon: Icons.event_available_rounded, title: 'Booking'),
          TabItem(icon: Icons.menu_book_rounded, title: 'Reports'),
          TabItem(icon: Icons.person_rounded, title: 'Profile'),
        ],
        initialActiveIndex: _index,
        onTap: (i) {
          if (mounted) setState(() => _index = i);
        },
      ),
    );
  }
}
