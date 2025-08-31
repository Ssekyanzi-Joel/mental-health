// Updated background.dart with Freud UI design inspiration
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // Reduce header height when keyboard is visible
    final headerHeight = isKeyboardVisible ? 180.0 : 240.0;
    final logoTopPosition = isKeyboardVisible ? 40.0 : 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F0), // Warm off-white from Freud UI
      resizeToAvoidBottomInset: true, // Allow UI to resize for keyboard
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: <Widget>[
            // Curved top section with Freud UI green - responsive height
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, headerHeight),
                painter: CurvedTopPainter(),
              ),
            ),

            // Logo/Brand section - responsive positioning
            Positioned(
              top: logoTopPosition,
              left: 0,
              right: 0,
              child: _buildLogoSection(isKeyboardVisible),
            ),

            // Main content - responsive top padding
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: headerHeight - 20, // Reduced space for curved section
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection([bool isCompact = false]) {
    return Column(
      children: [
        // Logo from assets - responsive size
        Container(
          width: isCompact ? 60 : 80,
          height: isCompact ? 60 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isCompact ? 15 : 20),
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: isCompact ? 24 : 32,
              height: isCompact ? 24 : 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: isCompact ? 12 : 20),

        // App name with elegant typography - responsive size
        Text(
          'Mind Aware',
          style: TextStyle(
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: isCompact ? 1.5 : 2,
          ),
        ),
      ],
    );
  }
}

// Custom painter for the curved top section
class CurvedTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 15, 40, 20), // Professional Blue
          const Color.fromARGB(255, 15, 40, 20), // Professional Blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Start from top left
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);

    // Create the curved bottom
    path.lineTo(size.width, size.height * 0.7);

    // Smooth curve
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.1,
      0,
      size.height * 0.7,
    );

    path.close();
    canvas.drawPath(path, paint);

    // Add subtle shadow effect
    final shadowPaint = Paint()
      ..color = const Color(0xFF9CAF7F).withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Alternative background with subtle pattern
class BackgroundWithPattern extends StatelessWidget {
  final Widget child;
  const BackgroundWithPattern({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // Reduce header height when keyboard is visible
    final headerHeight = isKeyboardVisible ? 180.0 : 240.0;
    final logoTopPosition = isKeyboardVisible ? 40.0 : 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F0),
      resizeToAvoidBottomInset: true, // Allow UI to resize for keyboard
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF9CAF7F).withOpacity(0.05),
              const Color(0xFFF5F2F0),
              const Color(0xFFF5F2F0),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle dot pattern
            Positioned.fill(child: CustomPaint(painter: DotPatternPainter())),

            // Main curved section - responsive height
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, headerHeight),
                painter: CurvedTopPainter(),
              ),
            ),

            // Logo section - responsive positioning
            Positioned(
              top: logoTopPosition,
              left: 0,
              right: 0,
              child: _buildLogoSection(isKeyboardVisible),
            ),

            // Main content - responsive top padding
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: headerHeight - 60),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection([bool isCompact = false]) {
    return Column(
      children: [
        Container(
          width: isCompact ? 60 : 80,
          height: isCompact ? 60 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isCompact ? 15 : 20),
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: isCompact ? 15 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: isCompact ? 24 : 32,
              height: isCompact ? 24 : 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: isCompact ? 12 : 20),
        Text(
          'mind.aware',
          style: TextStyle(
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: isCompact ? 1.5 : 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Subtle dot pattern painter for enhanced background
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9CAF7F).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final spacing = 40.0;
    final dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
