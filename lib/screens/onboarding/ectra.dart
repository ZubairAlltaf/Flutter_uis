import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

// This is a placeholder for your actual signup screen.
// Create a file 'SupernovaSignupScreen.dart' with a simple Scaffold
// to make this code runnable.
// e.g.,
// import 'package:flutter/material.dart';
// class SupernovaSignupScreen extends StatelessWidget {
//   const SupernovaSignupScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Welcome")),
//       body: const Center(child: Text("Signup Page")),
//     );
//   }
// }
import '../signup/SupernovaSignupScreen.dart';

// --- Fluid 'Liquid Reveal' Clipper by Zubair Altaf Dev ---
// A more organic and fluid alternative to the previous clipper.
class LiquidRevealClipper extends CustomClipper<Path> {
  final double revealPercent; // 0.0 to 1.0
  final Offset pullPoint;
  final bool isRevealingPrevious;

  LiquidRevealClipper({
    required this.revealPercent,
    required this.pullPoint,
    required this.isRevealingPrevious,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = size.height * 0.2 * (1 - math.cos(revealPercent * math.pi / 2));
    final controlPointHeight = waveHeight * 1.5 * math.sin(revealPercent * math.pi);

    if (isRevealingPrevious) {
      // Dragging Up: Reveal from the top
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, waveHeight);
      path.quadraticBezierTo(
        pullPoint.dx,
        controlPointHeight,
        size.width,
        waveHeight,
      );
      path.close();

    } else {
      // Dragging Down: Reveal from the bottom
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - waveHeight);
      path.quadraticBezierTo(
        pullPoint.dx,
        size.height - controlPointHeight,
        0,
        size.height - waveHeight,
      );
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant LiquidRevealClipper oldClipper) {
    return oldClipper.revealPercent != revealPercent ||
        oldClipper.pullPoint != pullPoint ||
        oldClipper.isRevealingPrevious != isRevealingPrevious;
  }
}


// --- Data Model for Onboarding Content ---
class OnboardingPageItem {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color accentColor;
  final Gradient backgroundGradient;

  OnboardingPageItem({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.accentColor,
  }) : backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
  );
}

// --- The Redesigned 'Liquid Cosmos' Onboarding Screen by Zubair Altaf Dev ---
class BiDirectionalGravitationalScreen extends StatefulWidget {
  const BiDirectionalGravitationalScreen({super.key});

  @override
  State<BiDirectionalGravitationalScreen> createState() => _BiDirectionalGravitationalScreenState();
}

class _BiDirectionalGravitationalScreenState extends State<BiDirectionalGravitationalScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _textFadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _textAnimation;

  int _currentPage = 0;
  double _dragPercent = 0.0;
  bool _isAnimating = false;
  bool _isRevealingPrevious = false;
  Offset _pullPoint = Offset.zero;
  bool _hasInteracted = false;

  final List<OnboardingPageItem> _onboardingData = [
    OnboardingPageItem(
      title: 'Explore Your Universe',
      description: 'Swipe up or down to navigate between worlds of possibility.',
      backgroundColor: const Color(0xFF0D1B2A),
      accentColor: const Color(0xFF38B0DE),
    ),
    OnboardingPageItem(
      title: 'Discover New Galaxies',
      description: 'Connect with ideas and people that expand your horizons.',
      backgroundColor: const Color(0xFF2C0735),
      accentColor: const Color(0xFFD43F8D),
    ),
    OnboardingPageItem(
      title: 'Chart Your Own Course',
      description: 'Your journey begins now. Create your profile and launch.',
      backgroundColor: const Color(0xFF0B3954),
      accentColor: const Color(0xFFFF9900),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _textAnimation = CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn);

    _animationController.addStatusListener(_onAnimationStatusChanged);
    _textFadeController.forward();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_isRevealingPrevious) {
          _currentPage = (_currentPage - 1).clamp(0, _onboardingData.length - 1);
        } else {
          _currentPage = (_currentPage + 1).clamp(0, _onboardingData.length - 1);
        }
        _dragPercent = 0.0;
        _isAnimating = false;
        _isRevealingPrevious = false;
        _animationController.reset();
        _textFadeController.forward(from: 0.0);
      });
    } else if (status == AnimationStatus.dismissed) {
      setState(() {
        _dragPercent = 0.0;
        _isAnimating = false;
        _isRevealingPrevious = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textFadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    if (!_hasInteracted) setState(() => _hasInteracted = true);

    double deltaY = details.delta.dy;
    double screenHeight = context.size!.height;

    // Dragging Down to reveal next page
    if (deltaY > 0 && _currentPage < _onboardingData.length - 1) {
      if(_isRevealingPrevious) _dragPercent = 0.0;
      _isRevealingPrevious = false;
      _dragPercent += deltaY / screenHeight;
    }
    // Dragging Up to reveal previous page
    else if (deltaY < 0 && _currentPage > 0) {
      if(!_isRevealingPrevious) _dragPercent = 0.0;
      _isRevealingPrevious = true;
      _dragPercent -= deltaY / screenHeight;
    }

    _dragPercent = _dragPercent.clamp(0.0, 1.0);
    _pullPoint = details.localPosition;
    _textFadeController.value = 1.0 - _dragPercent;
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating || _dragPercent == 0.0) return;

    _isAnimating = true;
    if (_dragPercent > 0.3) {
      _textFadeController.reverse();
      _animationController.forward(from: _dragPercent);
    } else {
      _animationController.reverse(from: _dragPercent);
      _textFadeController.forward(from: _textFadeController.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (_pullPoint == Offset.zero) _pullPoint = size.center(Offset.zero);

    final int backgroundPageIndex = _isRevealingPrevious ? _currentPage - 1 : _currentPage + 1;
    final int topPageIndex = _isRevealingPrevious ? _currentPage -1 : _currentPage;

    return Scaffold(
      body: Stack(
        children: [
          // Background page that gets revealed
          _buildPage(index: backgroundPageIndex),

          // Foreground page that is being clipped
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final currentReveal = _isAnimating ? _animationController.value : _dragPercent;
              return ClipPath(
                clipper: LiquidRevealClipper(
                    revealPercent: currentReveal,
                    pullPoint: _pullPoint,
                    isRevealingPrevious: _isRevealingPrevious
                ),
                child: child,
              );
            },
            child: _buildPage(index: _isRevealingPrevious ? _currentPage : topPageIndex ),
          ),

          // UI Elements
          _buildBottomUI(context),
          if (!_hasInteracted) _buildInstructionalOverlay(),
        ],
      ),
    );
  }

  Widget _buildPage({required int index}) {
    if (index < 0 || index >= _onboardingData.length) {
      return Container(color: Colors.black);
    }
    final item = _onboardingData[index];
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        decoration: BoxDecoration(gradient: item.backgroundGradient),
        child: Center(
          child: _buildMainVisual(item),
        ),
      ),
    );
  }

  Widget _buildMainVisual(OnboardingPageItem item) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _textFadeController]),
      builder: (context, child) {
        final currentReveal = _isAnimating ? _animationController.value : _dragPercent;
        final scale = 1.0 - (currentReveal * 0.3);
        final opacity = _textFadeController.value;
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: CustomPaint(
        painter: CosmicPulsarPainter(
          accentColor: _onboardingData[_currentPage].accentColor,
          pulseValue: _pulseController.value,
        ),
        size: const Size(250, 250),
      ),
    );
  }

  Widget _buildBottomUI(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 30, 40, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: FadeTransition(
          opacity: _textAnimation,
          child: _buildBottomContent(_onboardingData[_currentPage]),
        ),
      ),
    );
  }

  Widget _buildBottomContent(OnboardingPageItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_onboardingData.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: _currentPage == index ? 24.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? item.accentColor : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: item.accentColor, blurRadius: 15)],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), height: 1.5),
        ),
        const SizedBox(height: 40),
        if (_currentPage == _onboardingData.length - 1)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SupernovaSignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.accentColor,
              foregroundColor: item.backgroundColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              elevation: 8,
              shadowColor: item.accentColor,
            ),
            child: const Text('Launch Your Journey'),
          )
        else
          const SizedBox(height: 52), // Placeholder to maintain height
        const SizedBox(height: 10),
        Text("Dev by Zubair", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
      ],
    );
  }

  Widget _buildInstructionalOverlay() {
    return Align(
      alignment: Alignment.center,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _textAnimation,
          child: _SwipeInstruction(),
        ),
      ),
    );
  }
}

// --- Animated Swipe Instruction Widget ---
class _SwipeInstruction extends StatefulWidget {
  @override
  __SwipeInstructionState createState() => __SwipeInstructionState();
}

class __SwipeInstructionState extends State<_SwipeInstruction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animValue = _controller.value;
        final yOffset = (animValue * 50) - 25; // Moves from -25 to +25
        final opacity = 1.0 - (2 * (animValue - 0.5)).abs(); // Fades in and out

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, yOffset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_up, color: Colors.white.withOpacity(0.7)),
                const SizedBox(height: 8),
                Icon(Icons.touch_app, color: Colors.white.withOpacity(0.7), size: 30),
                const SizedBox(height: 8),
                Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.7)),
              ],
            ),
          ),
        );
      },
    );
  }
}


// --- Custom Painter for the 'Cosmic Pulsar' Visual ---
class CosmicPulsarPainter extends CustomPainter {
  final Color accentColor;
  final double pulseValue; // A value from 0.0 to 1.0

  CosmicPulsarPainter({required this.accentColor, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    // Outer glow
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, maxRadius, glowPaint);

    // Create a rotating gradient for the rings
    final sweepGradient = SweepGradient(
      colors: [accentColor.withOpacity(0.1), accentColor, accentColor.withOpacity(0.1)],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(pulseValue * math.pi * 2),
    );

    // Draw rotating rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: maxRadius));

    final ring1Radius = maxRadius * (0.8 + 0.05 * math.sin(pulseValue * math.pi * 2));
    ringPaint.strokeWidth = 3.0;
    canvas.drawCircle(center, ring1Radius, ringPaint);

    final ring2Radius = maxRadius * (0.6 - 0.05 * math.cos(pulseValue * math.pi * 2));
    ringPaint.strokeWidth = 1.5;
    canvas.drawCircle(center, ring2Radius, ringPaint..color = accentColor.withOpacity(0.5));

    // Inner core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, accentColor.withOpacity(0.5)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.3));
    canvas.drawCircle(center, maxRadius * 0.3, corePaint);
  }

  @override
  bool shouldRepaint(covariant CosmicPulsarPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.accentColor != accentColor;
  }
}