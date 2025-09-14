import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// Ensure you have the 'Orbitron' font added as per previous instructions.

class InterstellarLoginScreen extends StatefulWidget {
  const InterstellarLoginScreen({super.key});

  @override
  State<InterstellarLoginScreen> createState() =>
      _InterstellarLoginScreenState();
}

class _InterstellarLoginScreenState extends State<InterstellarLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundGradientController;
  late Animation<double> _backgroundGradientAnimation;

  late AnimationController _particleController;
  late List<Particle> _particles;

  late AnimationController _containerBreathingController;
  late Animation<double> _containerBreathingAnimation;

  late AnimationController _buttonGlowController;
  late Animation<double> _buttonGlowAnimation;

  late AnimationController _titleGlowController;
  late Animation<double> _titleGlowAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);

    // Background Gradient Animation (UPDATED COLORS)
    _backgroundGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // Slightly slower for more ethereal feel
    )..repeat(reverse: true);
    _backgroundGradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundGradientController,
        curve: Curves.easeInOutQuad, // More fluid curve
      ),
    );

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _particles = List.generate(300, (index) => Particle()); // More particles, subtle twinkling

    // Container Breathing Animation
    _containerBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower, more subtle breath
    )..repeat(reverse: true);
    _containerBreathingAnimation = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(
        parent: _containerBreathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Button Glow Animation (more dynamic)
    _buttonGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _buttonGlowAnimation =
        Tween<double>(begin: 4.0, end: 18.0).animate(CurvedAnimation( // More intense glow
          parent: _buttonGlowController,
          curve: Curves.easeInOut,
        ));

    // Title Glow Animation (subtle pulsate)
    _titleGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500)) // Slower title glow
      ..repeat(reverse: true);
    _titleGlowAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _titleGlowController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _backgroundGradientController.dispose();
    _particleController.dispose();
    _containerBreathingController.dispose();
    _buttonGlowController.dispose();
    _titleGlowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundGradientAnimation,
          _particleController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            size: size,
            painter: InterstellarBackgroundPainter(
              animationValue: _backgroundGradientAnimation.value,
              particleAnimationValue: _particleController.value,
              particles: _particles,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _containerBreathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _containerBreathingAnimation.value,
                      child: CustomPaint(
                        painter: IrregularContainerPainter(
                          borderColor: const Color(0xff00d4ff).withOpacity( // New accent color
                              0.6 + (_titleGlowAnimation.value * 0.3)),
                          animationValue: _backgroundGradientAnimation.value, // Pass animation for dynamic border
                        ),
                        child: ClipPath(
                          clipper: IrregularContainerClipper(),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // More blur for deeper glass effect
                            child: Container(
                              width: size.width * 0.9, // Slightly wider container
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 50), // More padding
                              decoration: BoxDecoration(
                                color: const Color(0xff0a041c).withOpacity(0.4), // Darker, more solid background for contrast
                                // No direct border here, it's handled by painter
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _titleGlowAnimation,
                                    builder: (context, child) {
                                      return Text(
                                        'ETHEREAL SHARD',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Orbitron',
                                          fontSize: 34, // Slightly larger title
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 4, // More spacing
                                          shadows: [
                                            Shadow(
                                              blurRadius: 18.0 * // More intense blur
                                                  (0.6 +
                                                      _titleGlowAnimation
                                                          .value *
                                                          0.4),
                                              color: const Color(0xff00d4ff) // New accent color
                                                  .withOpacity(
                                                  0.8 + _titleGlowAnimation.value * 0.2),
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 55), // Increased spacing
                                  _buildDataConduitField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hint: 'Galaxy ID (Email)',
                                    icon: Icons.alternate_email,
                                  ),
                                  const SizedBox(height: 30), // Increased spacing
                                  _buildDataConduitField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    hint: 'Star-Key (Password)',
                                    icon: Icons.vpn_key_outlined,
                                    obscure: true,
                                  ),
                                  const SizedBox(height: 60), // Increased spacing
                                  _buildWarpDriveButton(),
                                  const SizedBox(height: 25), // Increased spacing
                                  Text(
                                    'Access Protocols Corrupted? (Forgot Star-Key)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14, // Slightly larger text
                                      fontFamily: 'Orbitron',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataConduitField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18), // Slightly more rounded for contrast
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xff00d4ff).withOpacity(0.8) // Electric blue glow
              : Colors.white.withOpacity(0.15),
          width: 2.5, // Thicker border
        ),
        boxShadow: [
          if (focusNode.hasFocus)
            BoxShadow(
              color: const Color(0xff00d4ff).withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 3,
            ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Orbitron',
          fontSize: 17,
        ),
        cursorColor: const Color(0xff00d4ff), // Electric blue cursor
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 25), // More padding
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
          prefixIcon: Icon(icon, color: const Color(0xff00d4ff)), // Electric blue icon
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildWarpDriveButton() {
    return AnimatedBuilder(
      animation: _buttonGlowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45), // Slightly larger radius
            boxShadow: [
              BoxShadow(
                color: const Color(0xff00d4ff).withOpacity(0.8), // Electric blue glow
                blurRadius: _buttonGlowAnimation.value,
                spreadRadius: 3.0,
              ),
              BoxShadow(
                color: const Color(0xff4bffb5).withOpacity(0.5), // Neon green secondary glow
                blurRadius: _buttonGlowAnimation.value * 1.5,
                spreadRadius: 4.0,
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xff00d4ff), Color(0xff4bffb5)], // Electric blue to neon green
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(45),
              onTap: () {
                print('Initiating Warp Drive with:');
                print('Galaxy ID: ${_emailController.text}');
                print('Star-Key: ${_passwordController.text}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 35), // More padding
                child: Center(
                  child: Text(
                    'ENGAGE WARP DRIVE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20, // Larger text
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8), // Darker text for contrast with bright button
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          blurRadius: _buttonGlowAnimation.value * 0.4,
                          color: Colors.white.withOpacity(0.6),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ======================= CUSTOM PAINTERS & CLIPPER (MODIFIED) =======================

class InterstellarBackgroundPainter extends CustomPainter {
  final double animationValue;
  final double particleAnimationValue;
  final List<Particle> particles;

  InterstellarBackgroundPainter({
    required this.animationValue,
    required this.particleAnimationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Animated Gradient Background (Nebula Effect) - UPDATED COLORS
    final gradient = LinearGradient(
      begin: Alignment(
          -1.0 + animationValue * 2, -1.0 + animationValue * 2),
      end: Alignment(1.0 - animationValue * 2, 1.0 - animationValue * 2),
      colors: const [
        Color(0xff08001a), // Very Deep Space
        Color(0xff1a0a38), // Dark Violet
        Color(0xff00204a), // Deep Blue
        Color(0xff005c92), // Medium Blue
        Color(0xff00d4ff), // Electric Blue
        Color(0xff4bffb5), // Neon Green
      ],
      stops: const [0.0, 0.15, 0.35, 0.6, 0.8, 1.0], // Adjusted stops
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = gradient);

    // Animated Particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      final x = (p.initialPosition.dx * size.width +
          p.direction.dx * particleAnimationValue * size.width) %
          (size.width + 50);
      final y = (p.initialPosition.dy * size.height +
          p.direction.dy * particleAnimationValue * size.height) %
          (size.height + 50);

      particlePaint.color = p.color.withOpacity(0.4 + p.glowFactor * 0.6); // More visible glow
      canvas.drawCircle(Offset(x, y), p.radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant InterstellarBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.particleAnimationValue != particleAnimationValue;
  }
}

class Particle {
  final Offset initialPosition;
  final Offset direction;
  final double radius;
  final Color color;
  final double glowFactor;

  static final Random _random = Random();

  Particle()
      : initialPosition =
  Offset(_random.nextDouble(), _random.nextDouble()),
        direction = Offset(
            (_random.nextDouble() - 0.5) * 0.15, // Slightly faster movement
            (_random.nextDouble() - 0.5) * 0.15),
        radius = _random.nextDouble() * 1.2 + 0.8, // Larger particles
        color = Color.fromARGB(255, _random.nextInt(100) + 155,
            _random.nextInt(100) + 155, _random.nextInt(255)),
        glowFactor = _random.nextDouble();
}

// NEW IRREGULAR CONTAINER PAINTER WITH DYNAMIC BORDER COLORS
class IrregularContainerPainter extends CustomPainter {
  final Color borderColor;
  final double animationValue; // To make the border color dynamic

  IrregularContainerPainter({required this.borderColor, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final path = IrregularContainerClipper().getClip(size);

    // Draw a subtle inner shadow/glow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10.0), // Stronger blur
    );

    // Dynamic iridescent border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 // Thicker border
      ..shader = LinearGradient(
        begin: Alignment(
            -1.0 + animationValue * 2, -1.0 + animationValue * 2),
        end: Alignment(1.0 - animationValue * 2, 1.0 - animationValue * 2),
        colors: [
          borderColor.withOpacity(0.8),
          borderColor.withOpacity(0.4),
          const Color(0xff4bffb5).withOpacity(0.6), // Neon green shimmer
          borderColor.withOpacity(0.4),
          borderColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant IrregularContainerPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor || oldDelegate.animationValue != animationValue;
  }
}

// NEW IRREGULAR CONTAINER CLIPPER FOR SHARD SHAPE
class IrregularContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Define points for an asymmetrical, crystalline shard shape
    // These points are chosen to create sharp, non-rounded angles
    path.moveTo(size.width * 0.2, 0); // Top-left point
    path.lineTo(size.width * 0.8, 0); // Top-right point
    path.lineTo(size.width, size.height * 0.2); // First right spike
    path.lineTo(size.width * 0.9, size.height * 0.8); // Second right spike
    path.lineTo(size.width * 0.7, size.height); // Bottom-right point
    path.lineTo(size.width * 0.3, size.height); // Bottom-left point
    path.lineTo(size.width * 0.1, size.height * 0.8); // First left spike
    path.lineTo(0, size.height * 0.2); // Second left spike
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}