// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mind_aware_application/Screens/Welcome/welcome_screen.dart';
// import '../../responsive.dart';

// class WelcomeScreen1 extends StatelessWidget {
//   const WelcomeScreen1({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFF19351e), // Dark green background rgba(25,53,30,255)
//       ),
//       child: const SafeArea(
//         child: Responsive(
//           desktop: FullScreenWelcomeContent(),
//           mobile: MobileWelcomeScreen(),
//         ),
//       ),
//     );
//   }
// }

// class FullScreenWelcomeContent extends StatelessWidget {
//   const FullScreenWelcomeContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         const FullScreenDecorativeElements(),
//         // Centered content
//         Container(
//           width: double.infinity,
//           height: double.infinity,
//           padding: const EdgeInsets.all(40.0),
//           child: const Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               BrainIconSection(),
//               SizedBox(height: 40),
//               WelcomeTextSection(),
//               SizedBox(height: 40),
//               GetStartedSection(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BrainIconSection extends StatefulWidget {
//   const BrainIconSection({super.key});

//   @override
//   State<BrainIconSection> createState() => _BrainIconSectionState();
// }

// class _BrainIconSectionState extends State<BrainIconSection>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF81c784).withOpacity(0.3), // Light green
//                   Color(0xFF66bb6a).withOpacity(0.2), // Soft green
//                 ],
//               ),
//               border: Border.all(
//                 color: Color(
//                   0xFF4caf50,
//                 ).withOpacity(0.5), // Medium green border
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFF4caf50).withOpacity(0.3),
//                   blurRadius: 40,
//                   offset: const Offset(0, 20),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Image.asset(
//                 "assets/images/logo.png",
//                 width: 100,
//                 height: 80,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class FullScreenDecorativeElements extends StatefulWidget {
//   const FullScreenDecorativeElements({super.key});

//   @override
//   State<FullScreenDecorativeElements> createState() =>
//       _FullScreenDecorativeElementsState();
// }

// class _FullScreenDecorativeElementsState
//     extends State<FullScreenDecorativeElements>
//     with TickerProviderStateMixin {
//   late AnimationController _floatController;
//   late AnimationController _rotateController;
//   late AnimationController _starController;

//   @override
//   void initState() {
//     super.initState();
//     _floatController = AnimationController(
//       duration: const Duration(seconds: 8),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotateController = AnimationController(
//       duration: const Duration(seconds: 15),
//       vsync: this,
//     )..repeat();

//     _starController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _floatController.dispose();
//     _rotateController.dispose();
//     _starController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Floating circles with green glass morphism effect
//         AnimatedBuilder(
//           animation: _floatController,
//           builder: (context, child) {
//             return Positioned(
//               top: 100 + (_floatController.value * 20),
//               left: 150,
//               child: Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       Color(0xFF81c784).withOpacity(0.15), // Light green center
//                       Color(0xFF66bb6a).withOpacity(0.08), // Soft green edge
//                     ],
//                   ),
//                   border: Border.all(
//                     color: Color(0xFF4caf50).withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _floatController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 200 + (_floatController.value * -15),
//               left: 100,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       Color(0xFF66bb6a).withOpacity(0.2), // Soft green center
//                       Color(
//                         0xFF388e3c,
//                       ).withOpacity(0.1), // Slightly lighter green edge
//                     ],
//                   ),
//                   border: Border.all(
//                     color: Color(0xFF2e7d32).withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _floatController,
//           builder: (context, child) {
//             return Positioned(
//               top: 200 + (_floatController.value * 15),
//               right: 200,
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       Color(
//                         0xFF4caf50,
//                       ).withOpacity(0.18), // Medium green center
//                       Color(0xFF2e7d32).withOpacity(0.08), // Dark green edge
//                     ],
//                   ),
//                   border: Border.all(
//                     color: Color(0xFF388e3c).withOpacity(0.25),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _floatController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 300 + (_floatController.value * -10),
//               right: 150,
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Color(0xFF81c784).withOpacity(0.12),
//                   border: Border.all(
//                     color: Color(0xFF66bb6a).withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _floatController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 150 + (_floatController.value * -12),
//               right: 300,
//               child: Container(
//                 width: 90,
//                 height: 90,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       Color(0xFF388e3c).withOpacity(0.15),
//                       Color(0xFF2e7d32).withOpacity(0.08),
//                     ],
//                   ),
//                   border: Border.all(
//                     color: Color(0xFF4caf50).withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         // Geometric shapes with green tints
//         AnimatedBuilder(
//           animation: _rotateController,
//           builder: (context, child) {
//             return Positioned(
//               top: 150,
//               right: 700,
//               child: Transform.rotate(
//                 angle: _rotateController.value * 6.28 + 0.785,
//                 child: Container(
//                   width: 150,
//                   height: 150,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF66bb6a).withOpacity(0.12),
//                         Color(0xFF4caf50).withOpacity(0.08),
//                       ],
//                     ),
//                     border: Border.all(
//                       color: Color(0xFF388e3c).withOpacity(0.15),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _rotateController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 200,
//               left: 200,
//               child: Transform.rotate(
//                 angle: _rotateController.value * -6.28 + 0.524,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF81c784).withOpacity(0.15),
//                         Color(0xFF66bb6a).withOpacity(0.08),
//                       ],
//                     ),
//                     border: Border.all(
//                       color: Color(0xFF4caf50).withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         // Enhanced twinkling stars with better visibility
//         AnimatedBuilder(
//           animation: _starController,
//           builder: (context, child) {
//             return Positioned(
//               top: 80,
//               right: 100,
//               child: Opacity(
//                 opacity: 0.7 + (0.3 * _starController.value),
//                 child: Transform.scale(
//                   scale: 1.0 + (0.2 * _starController.value),
//                   child: Text(
//                     '★',
//                     style: TextStyle(
//                       color: Color(0xFFa5d6a7), // Brighter green
//                       fontSize: 24,
//                       fontWeight: FontWeight.normal,
//                       shadows: [
//                         Shadow(
//                           color: Color(0xFF4caf50).withOpacity(0.6),
//                           blurRadius: 4,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _starController,
//           builder: (context, child) {
//             return Positioned(
//               top: 450,
//               left: 80,
//               child: Opacity(
//                 opacity: 0.7 + (0.3 * (1 - _starController.value)),
//                 child: Transform.scale(
//                   scale: 1.0 + (0.2 * (1 - _starController.value)),
//                   child: Text(
//                     '★',
//                     style: TextStyle(
//                       color: Color(0xFF81c784), // Bright green
//                       fontSize: 20,
//                       fontWeight: FontWeight.normal,
//                       shadows: [
//                         Shadow(
//                           color: Color(0xFF388e3c).withOpacity(0.5),
//                           blurRadius: 3,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         AnimatedBuilder(
//           animation: _starController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 250,
//               right: 80,
//               child: Opacity(
//                 opacity: 0.7 + (0.3 * _starController.value),
//                 child: Transform.scale(
//                   scale: 1.0 + (0.2 * _starController.value),
//                   child: Text(
//                     '★',
//                     style: TextStyle(
//                       color: Color(0xFF66bb6a), // Medium bright green
//                       fontSize: 22,
//                       fontWeight: FontWeight.normal,
//                       shadows: [
//                         Shadow(
//                           color: Color(0xFF2e7d32).withOpacity(0.5),
//                           blurRadius: 3,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class WelcomeTextSection extends StatelessWidget {
//   const WelcomeTextSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 1200;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Welcome to text with professional styling
//         Text(
//           'Welcome to',
//           style: GoogleFonts.inter(
//             fontSize: isSmallScreen ? 24 : 32,
//             fontWeight: FontWeight.w300,
//             color: Color(0xFFa5d6a7), // Light mint green
//             letterSpacing: 2.5,
//             height: 1.2,
//             shadows: [
//               Shadow(
//                 color: Color(0xFF1b5e20).withOpacity(0.3),
//                 offset: Offset(0, 1),
//                 blurRadius: 3,
//               ),
//             ],
//           ),
//           textAlign: TextAlign.center,
//           overflow: TextOverflow.clip,
//         ),

//         const SizedBox(height: 8),

//         // Mind Aware - Main title with gradient and professional typography
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             'Mind Aware',
//             style: GoogleFonts.inter(
//               fontSize: isSmallScreen ? 48 : 68,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFFF5F5DC), // Cream color
//               letterSpacing: 3.0,
//               height: 1.1,
//               shadows: [
//                 Shadow(
//                   color: Color(0xFF1b5e20).withOpacity(0.4),
//                   offset: Offset(0, 2),
//                   blurRadius: 6,
//                 ),
//                 Shadow(
//                   color: Color(0xFF2e7d32).withOpacity(0.2),
//                   offset: Offset(0, 4),
//                   blurRadius: 12,
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Tagline with elegant styling
//         Text(
//           'Awareness • Growth • Strength',
//           style: GoogleFonts.playfairDisplay(
//             fontSize: isSmallScreen ? 18 : 24,
//             fontStyle: FontStyle.italic,
//             fontWeight: FontWeight.w400,
//             color: Color(0xFF81c784), // Soft green
//             letterSpacing: 1.5,
//             height: 1.4,
//             shadows: [
//               Shadow(
//                 color: Color(0xFF1b5e20).withOpacity(0.3),
//                 offset: Offset(0, 1),
//                 blurRadius: 3,
//               ),
//             ],
//           ),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }
// }

// class GetStartedSection extends StatelessWidget {
//   const GetStartedSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const GetStartedButton();
//   }
// }

// class GetStartedButton extends StatefulWidget {
//   const GetStartedButton({super.key});

//   @override
//   State<GetStartedButton> createState() => _GetStartedButtonState();
// }

// class _GetStartedButtonState extends State<GetStartedButton>
//     with SingleTickerProviderStateMixin {
//   bool _isLoading = false;
//   bool _isHovered = false;

//   void _handleGetStarted(BuildContext context) {
//     setState(() => _isLoading = true);
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const WelcomeScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         transform: Matrix4.identity()..translate(0.0, _isHovered ? -3.0 : 0.0),
//         child: Container(
//           width: 200, // Fixed width to prevent long button
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             gradient: _isHovered
//                 ? LinearGradient(
//                     colors: [Color(0xFF66bb6a), Color(0xFF4caf50)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   )
//                 : LinearGradient(
//                     colors: [
//                       Color(0xFF81c784).withOpacity(0.8),
//                       Color(0xFF66bb6a).withOpacity(0.9),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF4caf50).withOpacity(_isHovered ? 0.5 : 0.3),
//                 blurRadius: _isHovered ? 25 : 15,
//                 offset: Offset(0, _isHovered ? 8 : 5),
//                 spreadRadius: _isHovered ? 2 : 0,
//               ),
//               BoxShadow(
//                 color: Color(0xFF81c784).withOpacity(0.2),
//                 blurRadius: 40,
//                 offset: Offset(0, 20),
//               ),
//             ],
//           ),
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               foregroundColor: _isHovered ? Colors.white : Color(0xFF1b5e20),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 side: BorderSide(
//                   color: Colors.white.withOpacity(_isHovered ? 0.3 : 0.2),
//                   width: 1,
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//               elevation: 0,
//               shadowColor: Colors.transparent,
//             ),
//             onPressed: _isLoading ? null : () => _handleGetStarted(context),
//             child: SizedBox(
//               height: 24,
//               child: Center(
//                 child: _isLoading
//                     ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           color: _isHovered ? Colors.white : Color(0xFF2e7d32),
//                           strokeWidth: 2.5,
//                         ),
//                       )
//                     : Text(
//                         "GET STARTED",
//                         style: GoogleFonts.inter(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Mobile responsiveness
// class MobileWelcomeScreen extends StatelessWidget {
//   const MobileWelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFF19351e), // Same dark green background for mobile
//       ),
//       child: const SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 SizedBox(height: 60),
//                 MobileDecorativeElements(),
//                 SizedBox(height: 40),
//                 MobileBrainIcon(),
//                 SizedBox(height: 40),
//                 MobileWelcomeText(),
//                 SizedBox(height: 40),
//                 GetStartedButton(),
//                 SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MobileBrainIcon extends StatefulWidget {
//   const MobileBrainIcon({super.key});

//   @override
//   State<MobileBrainIcon> createState() => _MobileBrainIconState();
// }

// class _MobileBrainIconState extends State<MobileBrainIcon>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF81c784).withOpacity(0.3), // Light green
//                   Color(0xFF66bb6a).withOpacity(0.2), // Soft green
//                 ],
//               ),
//               border: Border.all(
//                 color: Color(0xFF4caf50).withOpacity(0.5),
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFF4caf50).withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Image.asset(
//                 "assets/images/logo.png",
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class MobileWelcomeText extends StatelessWidget {
//   const MobileWelcomeText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Column(
//       children: [
//         // Welcome to text with gradient
//         Text(
//           'Welcome to',
//           style: GoogleFonts.inter(
//             fontSize: 20,
//             fontWeight: FontWeight.w300,
//             color: Color(0xFFa5d6a7),
//             letterSpacing: 2.0,
//             height: 1.2,
//             shadows: [
//               Shadow(
//                 color: Color(0xFF1b5e20).withOpacity(0.3),
//                 offset: Offset(0, 1),
//                 blurRadius: 2,
//               ),
//             ],
//           ),
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: 4),

//         // Mind Aware title - responsive sizing
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             'Mind Aware',
//             style: GoogleFonts.inter(
//               fontSize: screenWidth > 350 ? 36 : 32,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFFF5F5DC),
//               letterSpacing: 2.0,
//               height: 1.1,
//               shadows: [
//                 Shadow(
//                   color: Color(0xFF1b5e20).withOpacity(0.4),
//                   offset: Offset(0, 2),
//                   blurRadius: 4,
//                 ),
//                 Shadow(
//                   color: Color(0xFF2e7d32).withOpacity(0.2),
//                   offset: Offset(0, 4),
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),

//         const SizedBox(height: 12),

//         // Tagline with professional styling
//         Container(
//           constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
//           child: ShaderMask(
//             shaderCallback: (bounds) => LinearGradient(
//               colors: [
//                 Color(0xFFa5d6a7).withOpacity(0.9),
//                 Color(0xFF81c784).withOpacity(0.8),
//               ],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ).createShader(bounds),
//             child: Text(
//               'Awareness • Growth • Strength',
//               style: GoogleFonts.playfairDisplay(
//                 fontSize: 16,
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.white,
//                 letterSpacing: 1.2,
//                 height: 1.4,
//                 shadows: [
//                   Shadow(
//                     color: Color(0xFF1b5e20).withOpacity(0.5),
//                     offset: Offset(0, 2),
//                     blurRadius: 4,
//                   ),
//                 ],
//               ),
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.visible,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class MobileDecorativeElements extends StatefulWidget {
//   const MobileDecorativeElements({super.key});

//   @override
//   State<MobileDecorativeElements> createState() =>
//       _MobileDecorativeElementsState();
// }

// class _MobileDecorativeElementsState extends State<MobileDecorativeElements>
//     with TickerProviderStateMixin {
//   late AnimationController _floatController;
//   late AnimationController _starController;

//   @override
//   void initState() {
//     super.initState();
//     _floatController = AnimationController(
//       duration: const Duration(seconds: 8),
//       vsync: this,
//     )..repeat(reverse: true);

//     _starController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _floatController.dispose();
//     _starController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 200,
//       child: Stack(
//         children: [
//           AnimatedBuilder(
//             animation: _floatController,
//             builder: (context, child) {
//               return Positioned(
//                 top: 30 + (_floatController.value * 15),
//                 left: 30,
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         Color(0xFF81c784).withOpacity(0.15),
//                         Color(0xFF66bb6a).withOpacity(0.08),
//                       ],
//                     ),
//                     border: Border.all(
//                       color: Color(0xFF4caf50).withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           AnimatedBuilder(
//             animation: _floatController,
//             builder: (context, child) {
//               return Positioned(
//                 bottom: 20 + (_floatController.value * -10),
//                 right: 40,
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         Color(0xFF66bb6a).withOpacity(0.18),
//                         Color(0xFF388e3c).withOpacity(0.08),
//                       ],
//                     ),
//                     border: Border.all(
//                       color: Color(0xFF2e7d32).withOpacity(0.25),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           // Enhanced mobile stars with better visibility
//           AnimatedBuilder(
//             animation: _starController,
//             builder: (context, child) {
//               return Positioned(
//                 top: 10,
//                 right: 20,
//                 child: Opacity(
//                   opacity: 0.8 + (0.2 * _starController.value),
//                   child: Transform.scale(
//                     scale: 1.3 + (0.3 * _starController.value),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0xFF81c784).withOpacity(0.7),
//                             blurRadius: 6,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         '★',
//                         style: TextStyle(
//                           color: Color(0xFFa5d6a7),
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               color: Color(0xFF4caf50).withOpacity(0.8),
//                               blurRadius: 4,
//                             ),
//                             Shadow(
//                               color: Colors.white.withOpacity(0.3),
//                               blurRadius: 8,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           AnimatedBuilder(
//             animation: _starController,
//             builder: (context, child) {
//               return Positioned(
//                 bottom: 20,
//                 left: 60,
//                 child: Opacity(
//                   opacity: 0.8 + (0.2 * (1 - _starController.value)),
//                   child: Transform.scale(
//                     scale: 1.3 + (0.3 * (1 - _starController.value)),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0xFF66bb6a).withOpacity(0.7),
//                             blurRadius: 5,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         '★',
//                         style: TextStyle(
//                           color: Color(0xFF81c784),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               color: Color(0xFF388e3c).withOpacity(0.8),
//                               blurRadius: 3,
//                             ),
//                             Shadow(
//                               color: Colors.white.withOpacity(0.2),
//                               blurRadius: 6,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
