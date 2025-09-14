import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// The main, mind-bending custom drawer widget.
class MedCustomDrawer5 extends StatefulWidget {
  const MedCustomDrawer5({super.key});

  @override
  State<MedCustomDrawer5> createState() => _MedCustomDrawer5State();
}

class _MedCustomDrawer5State extends State<MedCustomDrawer5> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipPath(
            clipper: _EtherealClipper(animationValue: _controller.value),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0D0A23).withOpacity(0.95),
                      const Color(0xFF1A1A3A).withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Color.lerp(const Color(0xFF00FFFF).withOpacity(0.8), const Color(0xFF00FF8C).withOpacity(0.8), _controller.value)!,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: -10,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00FF8C).withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated starfield background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StarfieldPainter(animationValue: _controller.value),
                      ),
                    ),
                    SingleChildScrollView(
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// A custom header with an ethereal floating icon.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1 + (value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(const Color(0xFF00FFFF).withOpacity(0.2), const Color(0xFF00FF00).withOpacity(0.2), value)!,
                        blurRadius: 100 * value,
                        spreadRadius: 20 * value,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              );
            },
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
                Shadow(color: Color(0xFF00FFFF), blurRadius: 10, offset: Offset(1, 0)),
                Shadow(color: Color(0xFFFF00FF), blurRadius: 10, offset: Offset(-1, 0)),
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
                Shadow(color: Color(0xFF00FFFF), blurRadius: 5, offset: Offset(1, 0)),
                Shadow(color: Color(0xFFFF00FF), blurRadius: 5, offset: Offset(-1, 0)),
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
          animation: _controller,
          builder: (context, child) {
            final double glow = _controller.value;
            final double scale = 1.0 + glow * 0.08;

            return Transform.scale(
              scale: scale,
              child: CustomPaint(
                painter: _CrystalPainter(glow: glow),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
                              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), glow)!,
                              blurRadius: 10 * glow,
                              offset: Offset(2 * glow, 0),
                            ),
                            Shadow(
                              color: Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FF00), glow)!,
                              blurRadius: 5 * glow,
                              offset: Offset(-2 * glow, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// A custom painter for the unique, ethereal crystal item shape.
class _CrystalPainter extends CustomPainter {
  final double glow;

  _CrystalPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), glow)!.withOpacity(0.1 + glow * 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), glow)!.withOpacity(0.5);

    // Create a flowing, asymmetric shape
    path.moveTo(size.width * 0.1, 0);
    path.cubicTo(size.width * 0.9, size.height * 0.1, size.width * 0.8, size.height * 0.9, size.width * 0.9, size.height);
    path.cubicTo(size.width * 0.1, size.height * 0.9, size.width * 0.2, size.height * 0.1, 0, size.height * 0.1);
    path.close();

    // Add multiple glowing shadows
    canvas.drawShadow(
      path,
      const Color(0xFF00FFFF).withOpacity(glow * 0.5),
      20 * glow,
      false,
    );
    canvas.drawShadow(
      path,
      const Color(0xFFFF00FF).withOpacity(glow * 0.5),
      20 * glow,
      false,
    );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CrystalPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}

// A custom clipper for the main drawer shape.
class _EtherealClipper extends CustomClipper<Path> {
  final double animationValue;

  _EtherealClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // A more flowing, animated path.
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      w * (0.8 + 0.1 * math.sin(animationValue * math.pi * 2)),
      h * 0.1,
      w * (0.8 + 0.1 * math.cos(animationValue * math.pi * 2)),
      h * 0.2,
    );
    path.cubicTo(
      w * (0.6 + 0.2 * math.sin(animationValue * 4 * math.pi)),
      h * 0.3,
      w * (0.9 + 0.1 * math.cos(animationValue * 4 * math.pi)),
      h * 0.7,
      w * (0.7 + 0.2 * math.sin(animationValue * 6 * math.pi)),
      h * 0.8,
    );
    path.quadraticBezierTo(
      w * 0.5,
      h * (0.9 + 0.05 * math.sin(animationValue * math.pi)),
      w,
      h,
    );
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _StarfieldPainter extends CustomPainter {
  final double animationValue;

  _StarfieldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint starPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final math.Random random = math.Random(0);

    for (int i = 0; i < 200; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double starSize = random.nextDouble() * 1.5;

      // Animate the shimmer of the stars
      final double shimmer = math.sin(animationValue * 2 * math.pi + (x + y) / 50) * 0.5 + 0.5;
      final double currentSize = starSize * shimmer;

      canvas.drawCircle(
        Offset(x, y),
        currentSize,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
