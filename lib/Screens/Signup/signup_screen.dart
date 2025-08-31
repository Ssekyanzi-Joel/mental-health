import 'package:flutter/material.dart';
import 'package:mind_aware_application/responsive.dart';
import '../../components/background.dart';

import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: const MobileSignupScreen(),
          desktop: Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: const SignUpForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child:
                  const SignUpForm(), // Removed height constraint for better keyboard handling
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
