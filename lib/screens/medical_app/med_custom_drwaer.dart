import 'dart:ui';
import 'package:flutter/material.dart';

class MedDrawerCustom extends StatelessWidget {
  const MedDrawerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipPath(
        clipper: _DrawerClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117).withOpacity(0.6),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: -10,
                )
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildDrawerItem(context, Icons.home_filled, 'Home'),
                _buildDrawerItem(context, Icons.inventory_2, 'Orders'),
                _buildDrawerItem(context, Icons.support_agent, 'Support'),
                _buildDrawerItem(context, Icons.logout_rounded, 'Sign Out'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
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
            ),
          ),
          const Text(
            'zubairalltafdev@gmail.com',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ]),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;

    // Start from top left, creating a dramatic top curve
    path.moveTo(0, 0);
    path.cubicTo(
      width * 0.7, height * 0.05,
      width * 1.0, -height * 0.05,
      width * 0.9, height * 0.2,
    );

    // Creates an inverted curve and sharp line down the side
    path.cubicTo(
      width * 0.8, height * 0.4,
      width * 0.8, height * 0.6,
      width * 0.95, height * 0.8,
    );

    // Creates a final sharp corner before closing the path
    path.quadraticBezierTo(
      width, height * 0.9,
      width * 0.8, height,
    );

    // Line to the bottom-left and close
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
