import 'package:flutter/material.dart';
import 'dart:math' as math;

// --- The 'Infinite Peel' Clipper ---
// This clipper creates a dynamic path that simulates a page peeling away.
class InfinitePeelClipper extends CustomClipper<Path> {
  final double peelPercent;

  InfinitePeelClipper({required this.peelPercent});

  @override
  Path getClip(Size size) {
    final path = Path();
    final halfHeight = size.height / 2;

    // The horizontal position of the start of the peel curve
    final peelStart = size.width - (size.width * peelPercent);
    // The depth of the curl, a parabolic effect
    final peelCurlDepth = size.width * 0.4 * (1 - math.pow(peelPercent - 0.5, 2) * 4);

    path.moveTo(0, 0);
    path.lineTo(peelStart, 0);

    // Draw a smooth, curling curve from top to bottom of the peel
    path.quadraticBezierTo(
      peelStart - peelCurlDepth, // Control point for the curve
      halfHeight,
      peelStart,
      size.height,
    );

    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant InfinitePeelClipper oldClipper) {
    return oldClipper.peelPercent != peelPercent;
  }
}

// --- Data Models ---
class PeelItem {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color textColor;

  PeelItem({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
  });
}

// --- The Master-Level 'Infinite Peel' Onboarding Screen by Zubair Altaf Dev ---
class InfinitePeelOnboardingScreen extends StatefulWidget {
  const InfinitePeelOnboardingScreen({super.key});

  @override
  State<InfinitePeelOnboardingScreen> createState() => _InfinitePeelOnboardingScreenState();
}

class _InfinitePeelOnboardingScreenState extends State<InfinitePeelOnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  int _currentPage = 0;
  double _dragPercent = 0.0;
  bool _isAnimating = false;

  final List<PeelItem> _onboardingData = [
    PeelItem(
      title: 'Peel to Reveal',
      description: 'Swipe left to peel back the layer and discover what\'s next.',
      backgroundColor: const Color(0xFF2E3B4E),
      textColor: Colors.white,
    ),
    PeelItem(
      title: 'Layers of Depth',
      description: 'Every interaction reveals a new dimension of design.',
      backgroundColor: const Color(0xFF9F285F),
      textColor: Colors.white,
    ),
    PeelItem(
      title: 'The Final Unfolding',
      description: 'You\'ve reached the end of the journey. Time to begin.',
      backgroundColor: const Color(0xFF1B6A88),
      textColor: Colors.white,
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
      if (_animationController.value == 1.0) {
        setState(() {
          if (_currentPage < _onboardingData.length - 1) {
            _currentPage++;
          }
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
      _animationController.forward(from: _dragPercent);
    } else {
      _animationController.reverse(from: _dragPercent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPageIndex = _currentPage < _onboardingData.length - 1 ? _currentPage + 1 : _currentPage;
    final nextItem = _onboardingData[nextPageIndex];
    final currentItem = _onboardingData[_currentPage];

    final currentPeel = _isAnimating ? _animationController.value : _dragPercent;

    return Scaffold(
      body: Stack(
        children: [
          // Background Page (The one being revealed)
          _buildPage(item: nextItem, isForeground: false, peelPercent: 0),

          // Foreground Page (The one being peeled away)
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: ClipPath(
              clipper: InfinitePeelClipper(peelPercent: currentPeel),
              child: _buildPage(item: currentItem, isForeground: true, peelPercent: currentPeel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required PeelItem item, required bool isForeground, required double peelPercent}) {
    // The background page will scale up slightly to enhance the peeling effect
    final scale = isForeground ? 1.0 : 0.8 + 0.2 * peelPercent;

    return Container(
      color: item.backgroundColor,
      child: Transform.scale(
        scale: scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: item.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: item.textColor.withOpacity(0.8),
                ),
              ),
              if (!isForeground && _currentPage == _onboardingData.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Onboarding Complete!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.textColor,
                      foregroundColor: item.backgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Get Started'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}