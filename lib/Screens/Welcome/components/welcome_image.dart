import 'package:flutter/material.dart';
import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Large image taking up more space
        SizedBox(
          width: double.infinity,
          height: 700, // Fixed height to make it bigger
          child: Image.asset(
            "images/MENTAL_HEALTHH.png",
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
