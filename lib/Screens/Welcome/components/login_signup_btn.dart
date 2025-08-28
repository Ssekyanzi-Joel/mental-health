// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginAndSignupBtn extends StatefulWidget {
  const LoginAndSignupBtn({super.key});

  @override
  State<LoginAndSignupBtn> createState() => _LoginAndSignupBtnState();
}

class _LoginAndSignupBtnState extends State<LoginAndSignupBtn> {
  bool _isHoveringLogin = false;
  bool _isHoveringSignup = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 60.0),

          child: Text(
            "MIND AWARE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2e7d32), // Dark green color
              fontSize: 40, // Large, prominent text
              letterSpacing: 2.0,
            ),
          ),
        ),

        // Login Button
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveringLogin = true),
          onExit: (_) => setState(() => _isHoveringLogin = false),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: _isHoveringLogin
                    ? [
                        Color(0xFF81c784),
                        Color(0xFF66bb6a),
                      ] // Light to soft green on hover
                    : [
                        Color(0xFF4caf50),
                        Color(0xFF2e7d32),
                      ], // Medium to dark green
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4caf50).withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: _isHoveringLogin
                    ? Color(0xFF2e7d32)
                    : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                "LOGIN".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Sign Up Button
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveringSignup = true),
          onExit: (_) => setState(() => _isHoveringSignup = false),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: _isHoveringSignup
                  ? Color(0xFF4caf50) // Medium green on hover
                  : Color(0xFFF5F5DC), // Cream background
              border: Border.all(
                color: _isHoveringSignup
                    ? Color(0xFF2e7d32)
                    : Color(0xFF66bb6a),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF66bb6a).withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: _isHoveringSignup
                    ? Colors.white
                    : Color(0xFF2e7d32),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: Text(
                "SIGN UP".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
