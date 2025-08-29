import 'package:flutter/material.dart';
import '../../responsive.dart';
import 'components/welcome_image.dart';
import '../Login/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-navigate to login screen after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    });

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF19351e), // Dark green background #19351e
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            desktop: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(child: WelcomeImage()),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "MIND AWARE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2e7d32),
                          fontSize: 40,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4caf50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Loading...",
                        style: TextStyle(
                          color: Color(0xFF66bb6a),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            mobile: const MobileWelcomeScreen(),
          ),
        ),
      ),
    );
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(
          0xFF19351e,
        ), // Dark green background #19351e for mobile too
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          WelcomeImage(),
          SizedBox(height: 40),
          Text(
            "MIND AWARE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2e7d32),
              fontSize: 32,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 30),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4caf50)),
          ),
          SizedBox(height: 20),
          Text(
            "Loading...",
            style: TextStyle(color: Color(0xFF66bb6a), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
