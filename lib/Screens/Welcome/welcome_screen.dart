// import 'package:flutter/material.dart';
// import '../../responsive.dart';
// import 'components/welcome_image.dart';
// import '../Login/login_screen.dart';

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _pulseController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Fade animation for smooth entrance
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );

//     // Pulse animation for loading indicator
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _startAnimations();
//     _navigateToLogin();
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//     _pulseController.repeat(reverse: true);
//   }

//   void _navigateToLogin() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 2000), () {
//         if (context.mounted) {
//           Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) =>
//                   const LoginScreen(),
//               transitionsBuilder:
//                   (context, animation, secondaryAnimation, child) {
//                     return FadeTransition(opacity: animation, child: child);
//                   },
//               transitionDuration: const Duration(milliseconds: 500),
//             ),
//           );
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF1a4d1f), // Deep forest green
//             Color(0xFF2e7d32), // Medium green
//             Color(0xFFe8f5e8), // Very light green (green-white blend)
//           ],
//           stops: [0.0, 0.6, 1.0],
//         ),
//       ),
//       child: SingleChildScrollView(
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Responsive(
//               mobile: _buildMobileLayout(),
//               desktop: _buildDesktopLayout(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileLayout() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const WelcomeImage(),
//         const SizedBox(height: 40),
//         _buildTitleWithGlow(),
//         const SizedBox(height: 50),
//         _buildAnimatedLoadingIndicator(),
//         const SizedBox(height: 30),
//         _buildLoadingText(),
//       ],
//     );
//   }

//   Widget _buildDesktopLayout() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         const Expanded(child: WelcomeImage()),
//         Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildTitleWithGlow(),
//               const SizedBox(height: 50),
//               _buildAnimatedLoadingIndicator(),
//               const SizedBox(height: 30),
//               _buildLoadingText(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTitleWithGlow() {
//     return ShaderMask(
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [
//           Color(0xFF1b5e20), // Dark green
//           Color(0xFF66bb6a), // Light green
//           Color(0xFFffffff), // White
//         ],
//       ).createShader(bounds),
//       child: const Text(
//         "MIND AWARE",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           fontSize: 32,
//           letterSpacing: 3.0,
//           shadows: [
//             Shadow(
//               color: Color(0x40000000),
//               offset: Offset(2, 2),
//               blurRadius: 4,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedLoadingIndicator() {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const RadialGradient(
//                 colors: [
//                   Color(0xFF81c784), // Light green
//                   Color(0xFFc8e6c9), // Very light green (green-white blend)
//                   Color(0xFFf1f8e9), // Almost white with green tint
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF4caf50).withOpacity(0.3),
//                   spreadRadius: 2,
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//             child: const CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2e7d32)),
//               backgroundColor: Color(0xFFe8f5e8),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoadingText() {
//     return Column(
//       children: [
//         Text(
//           "Loading your experience...",
//           style: TextStyle(
//             color: const Color(0xFF1b5e20).withOpacity(0.8),
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 8),
//         // Animated dots
//         AnimatedBuilder(
//           animation: _pulseController,
//           builder: (context, child) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(3, (index) {
//                 return AnimatedContainer(
//                   duration: Duration(milliseconds: 300 + (index * 100)),
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color.lerp(
//                       const Color(0xFF81c784),
//                       const Color(0xFFf1f8e9),
//                       (_pulseController.value + index * 0.3) % 1,
//                     ),
//                   ),
//                 );
//               }),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
