import 'package:flutter/material.dart';
import 'package:flutteruis/screens/onboarding/wavw_clipper.dart';
import 'dart:ui'; // For ImageFilter

// --- Data Model for Onboarding Content ---
// Now includes a custom painter for unique, coded visuals
class OnboardingItem {
  final String title;
  final String description;
  final CustomPainter painter;
  final Color backgroundColor;
  final Color accentColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.painter,
    required this.backgroundColor,
    required this.accentColor,
  });
}

// --- The Master-Level Liquid Onboarding Screen by Zubair Altaf Dev ---
class LiquidOnboardingScreen extends StatefulWidget {
  const LiquidOnboardingScreen({super.key});

  @override
  State<LiquidOnboardingScreen> createState() => _LiquidOnboardingScreenState();
}

class _LiquidOnboardingScreenState extends State<LiquidOnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  int _currentPage = 0;
  double _dragPercent = 0.0;
  bool _isAnimating = false;

  // --- Master-Level Onboarding Data with Custom Painters ---
  final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      title: 'Find Your Inner Peace',
      description: 'Discover guided meditations and calming sounds to help you relax and focus.',
      painter: PeacePainter(),
      backgroundColor: const Color(0xFF2C3E50),
      accentColor: const Color(0xFF3498DB),
    ),
    OnboardingItem(
      title: 'Chart Your Progress',
      description: 'Track your mindfulness journey and celebrate your achievements along the way.',
      painter: ProgressPainter(),
      backgroundColor: const Color(0xFF8E44AD),
      accentColor: const Color(0xFFF1C40F),
    ),
    OnboardingItem(
      title: 'Join a Community',
      description: 'Connect with like-minded people and share your experiences in a supportive space.',
      painter: CommunityPainter(),
      backgroundColor: const Color(0xFF2980B9),
      accentColor: const Color(0xFFE74C3C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_animation.value == 1.0) { // Successful swipe
        setState(() {
          if (_currentPage < _onboardingData.length - 1) {
            _currentPage++;
          }
          _dragPercent = 0.0;
        });
      } else { // Snap-back animation finished
        setState(() {
          _dragPercent = 0.0;
        });
      }
      _isAnimating = false;
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_onAnimationStatusChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAnimating || _currentPage == _onboardingData.length - 1) return;
    setState(() {
      _dragPercent -= details.primaryDelta! / (context.size!.width * 0.8);
      _dragPercent = _dragPercent.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isAnimating || _currentPage == _onboardingData.length - 1) return;

    _isAnimating = true;
    if (_dragPercent > 0.3) {
      _animation = Tween<double>(begin: _dragPercent, end: 1.0)
          .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    } else {
      _animation = Tween<double>(begin: _dragPercent, end: 0.0)
          .animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));
    }
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This structure is correct for preventing the mouse_tracker.dart error.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Stack(
          children: [
            // Background Page (The one being revealed)
            _buildPage(index: _currentPage + 1),

            // Foreground Page (The one being swiped away)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ClipPath(
                  clipper: LiquidClipper(
                    revealPercent: _isAnimating ? _animation.value : _dragPercent,
                  ),
                  child: child,
                );
              },
              child: _buildPage(index: _currentPage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required int index}) {
    if (index >= _onboardingData.length) {
      return Container(color: _onboardingData.last.backgroundColor);
    }

    final item = _onboardingData[index];
    return Container(
      color: item.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: CustomPaint(
                  painter: item.painter,
                  size: Size.infinite,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildBottomCard(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(int index) {
    final item = _onboardingData[index];
    final isLastPage = index == _onboardingData.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  item.title,
                  key: ValueKey<String>(item.title),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: item.backgroundColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              isLastPage ? _buildGetStartedButton(item) : _buildSwipeControls(item),
              const SizedBox(height: 10),
              const Text(
                "Dev by Zubair",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeControls(OnboardingItem item) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_onboardingData.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: item.accentColor.withOpacity(_currentPage == index ? 1.0 : 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        const Text(
          'SWIPE TO CONTINUE',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(OnboardingItem item) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Onboarding Complete!")),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: item.backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Get Started'),
    );
  }
}

// --- Custom Painters for Coded Vector Art ---

class PeacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = const Color(0xFF3498DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - 50)
          ..quadraticBezierTo(center.dx - 60, center.dy, center.dx, center.dy + 20)
          ..quadraticBezierTo(center.dx + 60, center.dy, center.dx, center.dy - 50),
        paint);

    // ✅ FIX: Corrected the invalid cast to use the proper Offset constructor.
    canvas.drawCircle(Offset(center.dx, center.dy - 70), 10, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset(center.dx - 80, center.dy + 40),
        Offset(center.dx + 80, center.dy + 40), paint..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = const Color(0xFFF1C40F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final path = Path()
      ..moveTo(center.dx - 80, center.dy + 40)
      ..lineTo(center.dx - 40, center.dy - 20)
      ..lineTo(center.dx + 20, center.dy + 10)
      ..lineTo(center.dx + 80, center.dy - 50);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(center.dx + 80, center.dy - 50), 8, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CommunityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = const Color(0xFFE74C3C)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFFE74C3C).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final p1 = Offset(center.dx, center.dy - 40);
    final p2 = Offset(center.dx - 50, center.dy + 30);
    final p3 = Offset(center.dx + 50, center.dy + 30);

    canvas.drawLine(p1, p2, linePaint);
    canvas.drawLine(p1, p3, linePaint);
    canvas.drawLine(p2, p3, linePaint);

    canvas.drawCircle(p1, 30, paint);

    // This implementation is correct.
    canvas.drawCircle(p2, 25, paint..color = paint.color.withOpacity(0.9));
    canvas.drawCircle(p3, 25, paint..color = paint.color.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
