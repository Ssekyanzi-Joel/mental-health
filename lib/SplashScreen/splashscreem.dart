// lib/SplashScreen/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mind_aware_application/Screens/Login/login_screen.dart';
import 'package:mind_aware_application/Screens/Welcome1/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Navigate safely after 3 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              //navigate to login screen
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
                 
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    var fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                    return FadeTransition(opacity: fade, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth > 600 ? 300 : 150;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 246), // deep green background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            "assets/images/logo.png", // Make sure this path is correct
            width: logoSize,
            height: logoSize,
            errorBuilder: (context, error, stackTrace) {
              // Prevent app freeze if image fails to load
              return const Icon(Icons.error, size: 100, color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}
