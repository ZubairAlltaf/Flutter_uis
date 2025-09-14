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

    _backgroundGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
    _backgroundGradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundGradientController,
        curve: Curves.easeInOutSine,
      ),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _particles = List.generate(200, (index) => Particle());

    _containerBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _containerBreathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _containerBreathingController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _buttonGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _buttonGlowAnimation =
        Tween<double>(begin: 3.0, end: 15.0).animate(CurvedAnimation(
          parent: _buttonGlowController,
          curve: Curves.easeInOut,
        ));

    _titleGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
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
                      child: AnimatedBuilder(
                        animation: _titleGlowAnimation,
                        builder: (context, child) {
                          // UPDATED: Using the new CrystallineShardPainter
                          return CustomPaint(
                            painter: CrystallineShardPainter(
                              borderColor: const Color(0xff00f5d4) // UPDATED: New Accent Color
                                  .withOpacity(0.5 + (_titleGlowAnimation.value * 0.3)),
                              glintAnimationValue: _titleGlowAnimation.value,
                            ),
                            child: child,
                          );
                        },
                        // UPDATED: The form container is now the child of the painter
                        child: ClipPath(
                          // UPDATED: Using the new CrystallineShardClipper
                          clipper: CrystallineShardClipper(),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: size.width * 0.88,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 40),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _titleGlowAnimation,
                                    builder: (context, child) {
                                      return Text(
                                        'CRYSTAL-AUTH', // UPDATED: New Title
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Orbitron',
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 3,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 15.0 *
                                                  (0.5 + _titleGlowAnimation.value * 0.5),
                                              color: const Color(0xff00f5d4) // UPDATED: New Accent Color
                                                  .withOpacity(0.7 + _titleGlowAnimation.value * 0.3),
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 45),
                                  _buildDataConduitField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hint: 'Shard ID (Email)',
                                    icon: Icons.data_usage,
                                  ),
                                  const SizedBox(height: 25),
                                  _buildDataConduitField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    hint: 'Geo-Key (Password)',
                                    icon: Icons.vpn_key_outlined,
                                    obscure: true,
                                  ),
                                  const SizedBox(height: 50),
                                  _buildWarpDriveButton(),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Shard ID Compromised?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
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
    // UPDATED: Using new accent colors
    const accentColor = Color(0xff00f5d4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: focusNode.hasFocus
              ? accentColor.withOpacity(0.7)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          if (focusNode.hasFocus)
            BoxShadow(
              color: accentColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.01),
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
          fontSize: 16,
        ),
        cursorColor: accentColor,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          prefixIcon: Icon(icon, color: accentColor),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildWarpDriveButton() {
    // UPDATED: New button colors
    const buttonColor1 = Color(0xff00bbf9);
    const buttonColor2 = Color(0xff00f5d4);

    return AnimatedBuilder(
      animation: _buttonGlowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: buttonColor1.withOpacity(0.7),
                blurRadius: _buttonGlowAnimation.value,
                spreadRadius: 2.0,
              ),
              BoxShadow(
                color: buttonColor2.withOpacity(0.4),
                blurRadius: _buttonGlowAnimation.value * 1.5,
                spreadRadius: 3.0,
              ),
            ],
            gradient: const LinearGradient(
              colors: [buttonColor1, buttonColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                print('Shard Authentication Initiated:');
                print('Shard ID: ${_emailController.text}');
                print('Geo-Key: ${_passwordController.text}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Center(
                  child: Text(
                    'AUTHENTICATE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8), // Dark text for contrast
                      letterSpacing: 2,
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

// ======================= UPDATED CUSTOM PAINTERS & CLIPPER =======================

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
    // UPDATED: New Nebula colors
    final gradient = LinearGradient(
      begin: Alignment(
          -1.0 + animationValue * 2, -1.0 + animationValue * 2),
      end: Alignment(1.0 - animationValue * 2, 1.0 - animationValue * 2),
      colors: const [
        Color(0xff0d1b2a),
        Color(0xff1b263b),
        Color(0xff415a77),
        Color(0xff0077b6),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = gradient);

    // Particles remain the same, they look great with any color scheme
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      final x = (p.initialPosition.dx * size.width +
          p.direction.dx * particleAnimationValue * size.width) %
          (size.width + 50);
      final y = (p.initialPosition.dy * size.height +
          p.direction.dy * particleAnimationValue * size.height) %
          (size.height + 50);

      particlePaint.color = p.color.withOpacity(0.3 + p.glowFactor * 0.7);
      canvas.drawCircle(Offset(x, y), p.radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant InterstellarBackgroundPainter oldDelegate) {
    return true; // Always repaint for smooth animations
  }
}

// NEW: This painter creates the shard border and the shimmering glints.
class CrystallineShardPainter extends CustomPainter {
  final Color borderColor;
  final double glintAnimationValue;

  CrystallineShardPainter({
    required this.borderColor,
    required this.glintAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = CrystallineShardClipper().getClip(size);

    // Draw the iridescent border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        colors: [
          borderColor,
          borderColor.withOpacity(0.1),
          Colors.white.withOpacity(0.3),
          borderColor.withOpacity(0.1),
          borderColor,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, borderPaint);

    // NEW: Draw shimmering glints on the sharp corners
    final glintPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Animate the opacity of the glints to make them twinkle
    double opacity = (sin(glintAnimationValue * 2 * pi) + 1) / 2; // oscillates between 0 and 1
    opacity = pow(opacity, 3).toDouble(); // a curve for a sharper twinkle

    // Coordinates of the sharpest corners from our clipper
    final List<Offset> sharpPoints = [
      Offset(size.width * 0.95, 0),
      Offset(size.width, size.height * 0.9),
      Offset(size.width * 0.1, size.height),
      Offset(0, size.height * 0.05),
    ];

    for (var point in sharpPoints) {
      canvas.drawCircle(point, 1.5, glintPaint..color = Colors.white.withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(covariant CrystallineShardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.glintAnimationValue != glintAnimationValue;
  }
}


// NEW: This clipper creates the unique shard shape with sharp corners.
class CrystallineShardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cornerCut = size.width * 0.05;

    // Start near top-left
    path.moveTo(cornerCut, 0);

    // Line to a deep cut at top-right
    path.lineTo(size.width - cornerCut, 0);
    path.lineTo(size.width, cornerCut);

    // Line to bottom-right with a different kind of cut
    path.lineTo(size.width, size.height - (cornerCut * 2));
    path.lineTo(size.width - (cornerCut * 2.5), size.height);

    // Line to bottom-left
    path.lineTo(cornerCut, size.height);

    // Line to top-left with a sharp point
    path.lineTo(0, size.height - cornerCut);
    path.lineTo(0, cornerCut * 1.5);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
            (_random.nextDouble() - 0.5) * 0.1,
            (_random.nextDouble() - 0.5) * 0.1),
        radius = _random.nextDouble() * 1.0 + 0.5,
        color = Color.fromARGB(255, _random.nextInt(100) + 155,
            _random.nextInt(100) + 155, 255), // Cooler tones for particles
        glowFactor = _random.nextDouble();
}