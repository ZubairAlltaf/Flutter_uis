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

  // CHANGED: Added a listener callback function
  void _onFocusChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // CHANGED: Added listeners to FocusNodes here
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);

    // Background Gradient Animation
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

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Longer duration for subtle movement
    )..repeat();
    _particles = List.generate(200, (index) => Particle()); // More particles

    // Container Breathing Animation
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

    // Button Glow Animation (more dynamic)
    _buttonGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _buttonGlowAnimation =
        Tween<double>(begin: 3.0, end: 15.0).animate(CurvedAnimation(
          parent: _buttonGlowController,
          curve: Curves.easeInOut,
        ));

    // Title Glow Animation (subtle pulsate)
    _titleGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
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

    // CHANGED: It's crucial to remove the listeners to avoid memory leaks
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
                          borderColor: Colors.purpleAccent.withOpacity(
                              0.5 + (_titleGlowAnimation.value * 0.2)),
                        ),
                        child: ClipPath(
                          clipper: IrregularContainerClipper(),
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
                                        'COSMIC PORTAL',
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
                                                  (0.5 +
                                                      _titleGlowAnimation
                                                          .value *
                                                          0.5), // Pulsating blur
                                              color: const Color(0xffc77dff)
                                                  .withOpacity(
                                                  0.7 + _titleGlowAnimation.value * 0.3),
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
                                    hint: 'Galaxy ID (Email)',
                                    icon: Icons.alternate_email,
                                  ),
                                  const SizedBox(height: 25),
                                  _buildDataConduitField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    hint: 'Star-Key (Password)',
                                    icon: Icons.vpn_key_outlined,
                                    obscure: true,
                                  ),
                                  const SizedBox(height: 50),
                                  _buildWarpDriveButton(),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Access Protocols Corrupted? (Forgot Star-Key)',
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

  // CHANGED: The entire widget is simplified, removing the `Focus` wrapper.
  Widget _buildDataConduitField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    // The Container now directly checks `focusNode.hasFocus` which works perfectly
    // because our listener in `initState` calls `setState` to trigger a rebuild on change.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xffc77dff).withOpacity(0.7)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          if (focusNode.hasFocus)
            BoxShadow(
              color: const Color(0xffc77dff).withOpacity(0.5),
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
        focusNode: focusNode, // TextField handles the focus logic internally
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Orbitron',
          fontSize: 16,
        ),
        cursorColor: const Color(0xffc77dff),
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          prefixIcon: Icon(icon, color: const Color(0xffc77dff)),
          border: InputBorder.none, // Remove default border
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
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff5a189a).withOpacity(0.7),
                blurRadius: _buttonGlowAnimation.value,
                spreadRadius: 2.0,
              ),
              BoxShadow(
                color: const Color(0xff9d4edd).withOpacity(0.4),
                blurRadius: _buttonGlowAnimation.value * 1.5,
                spreadRadius: 3.0,
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xff9d4edd), Color(0xff5a189a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                // Login logic goes here
                print('Initiating Warp Drive with:');
                print('Galaxy ID: ${_emailController.text}');
                print('Star-Key: ${_passwordController.text}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Center(
                  child: Text(
                    'ENGAGE WARP DRIVE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: _buttonGlowAnimation.value * 0.5,
                          color: Colors.white.withOpacity(0.5),
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

// ======================= CUSTOM PAINTERS & CLIPPER (Unchanged) =======================
// (The rest of the code for painters and clippers remains the same)

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
    final gradient = LinearGradient(
      begin: Alignment(
          -1.0 + animationValue * 2, -1.0 + animationValue * 2),
      end: Alignment(1.0 - animationValue * 2, 1.0 - animationValue * 2),
      colors: const [
        Color(0xff0a041c),
        Color(0xff2a0b4d),
        Color(0xff5c176e),
        Color(0xff8c2691),
        Color(0xffc77dff),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = gradient);

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
            (_random.nextDouble() - 0.5) * 0.1,
            (_random.nextDouble() - 0.5) * 0.1),
        radius = _random.nextDouble() * 1.0 + 0.5,
        color = Color.fromARGB(255, _random.nextInt(100) + 155,
            _random.nextInt(100) + 155, _random.nextInt(255)),
        glowFactor = _random.nextDouble();
}

class IrregularContainerPainter extends CustomPainter {
  final Color borderColor;

  IrregularContainerPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = IrregularContainerClipper().getClip(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = LinearGradient(
        colors: [
          borderColor,
          borderColor.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
          borderColor.withOpacity(0.3),
          borderColor,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant IrregularContainerPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor;
  }
}

class IrregularContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, 0);
    path.lineTo(size.width * 0.85, 0);
    path.quadraticBezierTo(
        size.width, 0, size.width, size.height * 0.15);
    path.lineTo(size.width, size.height * 0.85);
    path.quadraticBezierTo(size.width, size.height, size.width * 0.85,
        size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.quadraticBezierTo(
        0, size.height, 0, size.height * 0.85);
    path.lineTo(0, size.height * 0.15);
    path.quadraticBezierTo(0, 0, size.width * 0.15, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}