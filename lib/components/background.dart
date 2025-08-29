// Updated background.dart with Freud UI design inspiration
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F0), // Warm off-white from Freud UI
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            // Curved top section with Freud UI green
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 300),
                painter: CurvedTopPainter(),
              ),
            ),

            // Logo/Brand section
            Positioned(top: 80, left: 0, right: 0, child: _buildLogoSection()),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 300,
                ), // Space for curved section
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Four-dot logo inspired by Freud UI
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(32, 32),
              painter: FourDotLogoPainter(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // App name with elegant typography
        Text(
          'Mind Aware',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 2,
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
          const Color(0xFF9CAF7F), // Main green from Freud UI
          const Color(0xFF9CAF7F).withOpacity(0.8),
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

// Custom painter for the four-dot logo
class FourDotLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final spacing = size.width * 0.25;

    // Draw four dots in a diamond/cross pattern
    final positions = [
      Offset(center.dx, center.dy - spacing), // Top
      Offset(center.dx + spacing, center.dy), // Right
      Offset(center.dx, center.dy + spacing), // Bottom
      Offset(center.dx - spacing, center.dy), // Left
    ];

    for (final position in positions) {
      canvas.drawCircle(position, dotRadius, paint);
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F0),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
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

            // Main curved section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 280),
                painter: CurvedTopPainter(),
              ),
            ),

            // Logo section
            Positioned(top: 80, left: 0, right: 0, child: _buildLogoSection()),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 160),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(32, 32),
              painter: FourDotLogoPainter(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'mind.aware',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 2,
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
