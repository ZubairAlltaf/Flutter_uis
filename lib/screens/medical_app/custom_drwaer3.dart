import 'dart:ui';
import 'package:flutter/material.dart';

class MedCustomDrawer3 extends StatefulWidget {
  const MedCustomDrawer3({super.key});

  @override
  State<MedCustomDrawer3> createState() => _MedCustomDrawer3State();
}

class _MedCustomDrawer3State extends State<MedCustomDrawer3> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      // Use the new custom clipper for the "fractal" shape.
      child: ClipPath(
        clipper: _FractalDrawerClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF000033).withOpacity(0.9), // Deep dark blue
                  const Color(0xFF1a0033).withOpacity(0.9), // Dark violet
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.8), // Neon cyan border
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5), // Neon cyan glow
                  blurRadius: 50,
                  spreadRadius: -10,
                )
              ],
            ),
            // Use SingleChildScrollView to prevent overflow.
            child: SingleChildScrollView(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(),
                  SizedBox(height: 20),
                  CrazyDrawerItem(icon: Icons.home_filled, title: 'Home'),
                  CrazyDrawerItem(icon: Icons.inventory_2, title: 'Orders'),
                  CrazyDrawerItem(icon: Icons.support_agent, title: 'Support'),
                  CrazyDrawerItem(icon: Icons.logout_rounded, title: 'Sign Out'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A custom header with a "glitch" animation on the avatar.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glitchy avatar container.
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.5), // Neon cyan
                  const Color(0xFF1a0033).withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Zubair Altaf',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF), // Neon cyan shadow
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const Text(
            'zubairalltafdev@gmail.com',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF), // Neon cyan shadow
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom drawer item with an interactive, glowing effect.
class CrazyDrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;

  const CrazyDrawerItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  State<CrazyDrawerItem> createState() => _CrazyDrawerItemState();
}

class _CrazyDrawerItemState extends State<CrazyDrawerItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0.0).then((_) {
      _controller.reverse();
    });
    // Add navigation logic here.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final double glow = _glowAnimation.value;
            return ClipPath(
              clipper: _ItemClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FFFF).withOpacity(0.1 + glow * 0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(glow * 0.5),
                      blurRadius: 20 * glow,
                      spreadRadius: 5 * glow,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Color.lerp(
                        const Color(0xFF00FFFF),
                        const Color(0xFFFFFFFF),
                        glow,
                      ),
                      size: 28,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00FFFF).withOpacity(glow),
                            blurRadius: 10 * glow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// A more dramatic custom clipper for a "fractal" or "digital shard" effect.
class _FractalDrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Start at top-left
    path.moveTo(0, 0);

    // Create a series of jagged, angular lines down the right side.
    path.lineTo(w * 0.95, h * 0.05);
    path.lineTo(w * 0.85, h * 0.2);
    path.lineTo(w * 0.95, h * 0.35);
    path.lineTo(w * 0.8, h * 0.5);
    path.lineTo(w * 0.95, h * 0.65);
    path.lineTo(w * 0.85, h * 0.8);
    path.lineTo(w, h * 0.95);

    // Line to the bottom-left and back to the start.
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// A custom clipper for a unique, angled item shape.
class _ItemClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.05, 0);
    path.lineTo(w, 0);
    path.lineTo(w * 0.95, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
