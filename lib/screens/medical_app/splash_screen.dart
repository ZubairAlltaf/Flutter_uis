import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'med_home_screen.dart';


class medSplashScreen extends StatefulWidget {
  const medSplashScreen({super.key});

  @override
  State<medSplashScreen> createState() => _medSplashScreenState();
}

class _medSplashScreenState extends State<medSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );

    // Animate the glow effect
    _controller.repeat(reverse: true);

    // Navigate to the next screen after the splash duration
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (_, __, ___) => const MedHomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with a pulsating glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(_glowAnimation.value),
                        blurRadius: 20.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.healing, // Using a standard icon for simplicity, can be replaced with a custom SVG
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'InstantMed',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            const Text(
              'Medicines at your doorstep in 15–30 mins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            // Loader
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
