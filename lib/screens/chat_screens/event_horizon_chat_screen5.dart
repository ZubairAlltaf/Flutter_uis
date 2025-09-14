import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Ensure these paths are correct for your project structure
import '../../providers/chat_provider.dart';

// A seed for generating a consistent, winding path for the chat timeline.
final int _pathSeed = Random().nextInt(1000);

///
/// EventHorizonChatScreen
///
/// A redesign of a chat UI with a "singularity" and "event horizon" theme.
/// The conversation timeline is a "chrono-stream," and messages are crystalline
/// "chrono-fragments" emanating from the "singularity" input at the bottom.
///
class EventHorizonChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const EventHorizonChatScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<EventHorizonChatScreen> createState() => _EventHorizonChatScreenState();
}

class _EventHorizonChatScreenState extends State<EventHorizonChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  Timer? _typingTimer;

  // Animation Controllers
  late AnimationController _enterAnimationController;
  late AnimationController _bgAnimationController;
  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();
    // For initial screen load animations
    _enterAnimationController = AnimationController(vsync: this, duration: 800.ms);
    // For continuous background animations (nebula movement)
    _bgAnimationController = AnimationController(vsync: this, duration: 45.seconds)..repeat(reverse: true);
    // For the pulsing singularity input effect
    _pulseAnimationController = AnimationController(vsync: this, duration: 3.seconds, lowerBound: 0.5, upperBound: 1.0)..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _messageController.addListener(_onTextChanged);
      _chatProvider?.updateUserTypingStatus(widget.chatId, false);
      _enterAnimationController.forward();

      // Scroll to the bottom on initial load after a brief delay for animations
      Timer(600.ms, () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: 1.seconds,
            curve: Curves.easeInOutCubic,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _enterAnimationController.dispose();
    _bgAnimationController.dispose();
    _pulseAnimationController.dispose();
    // Ensure typing status is set to false when leaving the screen
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    super.dispose();
  }

  void _onTextChanged() {
    if (_chatProvider == null || !mounted) return;
    if (_messageController.text.isNotEmpty) {
      // Make pulse more intense while typing
      _pulseAnimationController.animateTo(1.0, duration: 300.ms, curve: Curves.easeOut);
      _chatProvider!.updateUserTypingStatus(widget.chatId, true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _chatProvider!.updateUserTypingStatus(widget.chatId, false);
          // Return pulse to normal breathing animation
          _pulseAnimationController.repeat(reverse: true);
        }
      });
    } else {
      _chatProvider!.updateUserTypingStatus(widget.chatId, false);
      _pulseAnimationController.repeat(reverse: true);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatProvider?.user == null) return;
    final currentUser = _chatProvider!.user!;

    // Clear controller and reset typing status
    _messageController.clear();
    FocusScope.of(context).unfocus();
    _typingTimer?.cancel();
    _chatProvider!.updateUserTypingStatus(widget.chatId, false);

    final messageData = {
      'senderId': currentUser.uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'seed': Random().nextDouble(), // Unique seed for the message's crystalline shape
    };

    // Add message to Firestore
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add(messageData);

    // Update the parent chat document for chat list ordering and preview
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Animate to the newly sent message
    Timer(100.ms, () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020413),
      extendBodyBehindAppBar: true,
      appBar: _buildHolographicHeader(),
      body: Stack(
        children: [
          // The main animated background
          GravityWellBackground(
            bgAnimation: _bgAnimationController,
            pulseAnimation: _pulseAnimationController,
          ),
          // The message list and its timeline painter
          _buildChronoStream(),
          // The input field at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildSingularityInput(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHolographicHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: Animate(
        controller: _enterAnimationController,
        effects: [
          FadeEffect(duration: 500.ms),
          SlideEffect(begin: Offset(0, -0.5), curve: Curves.easeOutCubic),
        ],
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, left: 5, right: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff0d111c).withOpacity(0.1),
                const Color(0xff0d111c).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.cyan.withOpacity(0.3), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(color: Colors.cyan.withOpacity(0.2), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.cyan.withOpacity(0.7), blurRadius: 10, spreadRadius: 1)
                  ],
                ),
                child: AvatarWithFallback(
                  imageUrl: widget.otherUser['avatar'],
                  name: widget.otherUser['name'],
                  radius: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.otherUser['name'] ?? 'Chat',
                  style: GoogleFonts.exo(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChronoStream() {
    final currentUserId = context.watch<ChatProvider>().user?.uid;
    return CustomPaint(
      painter: _ChronoStreamPainter(scrollController: _scrollController, pathSeed: _pathSeed),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyan));
          }
          final messages = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 120, bottom: 150, left: 20, right: 20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msgData = messages[index].data() as Map<String, dynamic>;
              final isMe = msgData['senderId'] == currentUserId;
              return _ChronoFragment(
                message: msgData,
                isMe: isMe,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSingularityInput() {
    return Animate(
      controller: _enterAnimationController,
      effects: [
        FadeEffect(duration: 500.ms, delay: 200.ms),
        SlideEffect(begin: Offset(0, 0.5), curve: Curves.easeOutCubic),
      ],
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: SizedBox(
          height: 100,
          child: CustomPaint(
            painter: _SingularityInputPainter(animation: _pulseAnimationController),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10).copyWith(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.exo(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Transmit into the quantum foam...',
                        hintStyle: GoogleFonts.exo(color: Colors.white.withOpacity(0.4)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const Icon(Icons.send_rounded, color: Colors.white70, size: 28)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(delay: 2.seconds, duration: 1.seconds, color: Colors.purpleAccent.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- All Custom Widgets & Painters ---

class _ChronoFragment extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _ChronoFragment({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final seed = (message['seed'] as double?) ?? 0.5;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ChronoFragmentPainter(
              isMe: isMe,
              seed: seed,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Text(
                message['content'] ?? '',
                style: GoogleFonts.exo(color: Colors.white.withOpacity(0.95), fontSize: 16, height: 1.4),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .scaleXY(begin: 0.5, duration: 600.ms, curve: Curves.elasticOut)
        .slideX(begin: isMe ? 0.3 : -0.3, curve: Curves.easeOutQuart)
        .shimmer(delay: 400.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.1));
  }
}

class _ChronoFragmentPainter extends CustomPainter {
  final bool isMe;
  final double seed;
  late final Timer _timer;

  // This painter will repaint on its own via the timer, creating a live effect
  _ChronoFragmentPainter({required this.isMe, required this.seed}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((seed * 1000).toInt());
    final paint = Paint();
    final path = Path();

    // Create a sharp, crystalline, asymmetric shape
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width, size.height * (0.1 + random.nextDouble() * 0.2));
    path.lineTo(size.width * (0.9 + random.nextDouble() * 0.1), size.height);
    path.lineTo(0, size.height * (0.9 - random.nextDouble() * 0.2));
    path.close();

    // Core gradient fill
    final coreColor1 = isMe ? const Color(0xFF4a0e66) : const Color(0xFF003973);
    final coreColor2 = isMe ? const Color(0xFF9c27b0) : const Color(0xFF03A9F4);
    paint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, size.height),
      [coreColor1.withOpacity(0.6), coreColor2.withOpacity(0.4)],
    );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);

    // Animated Scanline/Glitch Effect
    final scanlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.5;
    final lineCount = 10;
    final time = DateTime.now().millisecondsSinceEpoch / 500.0;
    for (int i = 0; i < lineCount; i++) {
      final y = ( (i / lineCount) * size.height + (time + seed * 10) * 10) % size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }
    canvas.restore();

    // Glowing border
    paint
      ..shader = null
      ..color = isMe ? Colors.purpleAccent.withOpacity(0.8) : Colors.cyanAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChronoFragmentPainter oldDelegate) => false;
}

class _ChronoStreamPainter extends CustomPainter {
  final ScrollController scrollController;
  final int pathSeed;

  _ChronoStreamPainter({required this.scrollController, required this.pathSeed})
      : super(repaint: scrollController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final path = Path();
    final random = Random(pathSeed);

    final scrollOffset = scrollController.hasClients ? scrollController.offset : 0.0;
    final totalHeight = scrollController.hasClients
        ? scrollController.position.maxScrollExtent + size.height
        : size.height;

    final points = <Offset>[];
    final segments = 20;
    for (int i = 0; i <= segments; i++) {
      final y = (i / segments) * totalHeight;
      final x = size.width / 2 + sin(i * 0.4 + random.nextDouble()) * (size.width * 0.25);
      points.add(Offset(x, y - scrollOffset));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i+1];
      final midPoint = Offset((p1.dx + p2.dx)/2, (p1.dy + p2.dy)/2);
      path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
    }

    // Draw the outer, blurred glow of the stream
    paint
      ..shader = ui.Gradient.linear(
          Offset(0, 0), Offset(0, size.height),
          [Colors.purpleAccent.withOpacity(0.6), Colors.cyanAccent.withOpacity(0.6)])
      ..strokeWidth = 3.0
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);
    canvas.drawPath(path, paint);

    // Draw the inner, brighter core of the stream
    paint
      ..shader = null
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 0.5
      ..maskFilter = null;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SingularityInputPainter extends CustomPainter {
  final Animation<double> animation;
  _SingularityInputPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // Defines the curved top shape of the input area
    path.moveTo(0, size.height);
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width / 2, -10, size.width, 20);
    path.lineTo(size.width, size.height);
    path.close();

    // Pulsing Glow effect
    final glowPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.3 * animation.value)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0 + 15 * animation.value);
    canvas.drawPath(path, glowPaint);

    // Solid background with gradient
    paint.shader = ui.Gradient.linear(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        [const Color(0xff1a1f36).withOpacity(0.9), const Color(0xff0d111c).withOpacity(0.95)]
    );
    canvas.drawPath(path, paint);

    // Top border line
    final borderPaint = Paint()
      ..shader = ui.Gradient.linear(
          Offset.zero, Offset(size.width, 0),
          [Colors.purpleAccent.withOpacity(0.8), Colors.cyanAccent.withOpacity(0.8)])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final borderPath = Path();
    borderPath.moveTo(0, 20);
    borderPath.quadraticBezierTo(size.width / 2, -10, size.width, 20);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SingularityInputPainter oldDelegate) => oldDelegate.animation.value != animation.value;
}

class GravityWellBackground extends StatelessWidget {
  final Animation<double> bgAnimation;
  final Animation<double> pulseAnimation;
  const GravityWellBackground({super.key, required this.bgAnimation, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.8),
              radius: 1.5,
              colors: [Color(0xff1a1a3f), Color(0xff020413)],
            ),
          ),
        ),
        // Upward flowing stardust
        const Stardust(),
        // Twinkling stars
        ...List.generate(60, (index) => Star(seed: index)),
        // Animated background nebula blobs
        AnimatedBuilder(
          animation: bgAnimation,
          builder: (context, child) {
            final value = bgAnimation.value;
            return Stack(
              children: [
                _AetherBlob(
                  color: Colors.purple.withOpacity(0.1),
                  size: 500,
                  alignment: Alignment(ui.lerpDouble(-1.5, 1.5, value)!, ui.lerpDouble(-1.2, 1.2, value)!),
                ),
                _AetherBlob(
                  color: Colors.cyan.withOpacity(0.1),
                  size: 400,
                  alignment: Alignment(ui.lerpDouble(1.5, -1.5, value)!, ui.lerpDouble(1.2, -1.2, value)!),
                ),
              ],
            );
          },
        ),
        // Pulsing glow from the singularity input area
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                final value = pulseAnimation.value;
                return Container(
                  width: 400 + 100 * value,
                  height: 300 + 80 * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withOpacity(0.2 * value),
                        Colors.purple.withOpacity(0),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}

class Star extends StatefulWidget {
  final int seed;
  const Star({super.key, required this.seed});

  @override
  State<Star> createState() => _StarState();
}

class _StarState extends State<Star> {
  late double _opacity;
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _opacity = Random(widget.seed).nextDouble() * 0.6 + 0.2;
    _scheduleTwinkle();
  }

  void _scheduleTwinkle() {
    final random = Random(widget.seed + DateTime.now().microsecond);
    _duration = (random.nextInt(4000) + 2000).ms;
    _timer = Timer(_duration, () {
      if (mounted) {
        setState(() => _opacity = random.nextDouble() * 0.6 + 0.2);
        _scheduleTwinkle();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random(widget.seed);
    final size = random.nextDouble() * 1.8 + 0.5;
    return Positioned(
      top: random.nextDouble() * MediaQuery.of(context).size.height,
      left: random.nextDouble() * MediaQuery.of(context).size.width,
      child: AnimatedContainer(
        duration: _duration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(_opacity * 0.5), blurRadius: size * 2, spreadRadius: size * 0.5)
          ],
        ),
      ),
    );
  }
}

class Stardust extends StatefulWidget {
  const Stardust({super.key});
  @override
  State<Stardust> createState() => _StardustState();
}

class _StardustState extends State<Stardust> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DustParticle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 10.seconds)..repeat();
    particles = List.generate(100, (index) => _DustParticle(index));
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
        return CustomPaint(
          painter: _StardustPainter(particles: particles, animationValue: _controller.value),
        );
      },
    );
  }
}

class _DustParticle {
  final int seed;
  late double x, y, size, initialY;

  _DustParticle(this.seed) {
    final random = Random(seed);
    x = random.nextDouble();
    y = random.nextDouble();
    initialY = y;
    size = random.nextDouble() * 1.2 + 0.2;
  }
}

class _StardustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double animationValue;

  _StardustPainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.5);
    for (var p in particles) {
      final currentY = (p.initialY - animationValue) % 1.0;
      final opacity = (1.0 - currentY) * 0.5;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(p.x * size.width, currentY * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StardustPainter oldDelegate) => true;
}

class _AetherBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;
  const _AetherBlob({required this.color, required this.size, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(decoration: const BoxDecoration(shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

// Re-usable Avatar widget from original code, slightly tweaked for the new theme
class AvatarWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  const AvatarWithFallback({super.key, this.imageUrl, this.name, this.radius = 25});

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? 'A';
    final bool hasValidImage = imageUrl != null && imageUrl!.isNotEmpty && !imageUrl!.contains('placeholder');
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: hasValidImage
            ? Image.network(
          imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(displayName),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54));
          },
        )
            : _buildFallback(displayName),
      ),
    );
  }

  Widget _buildFallback(String displayName) {
    final hash = displayName.hashCode;
    final color1 = Color((hash & 0xFF0000) | 0xFF3C1053);
    final color2 = Color((hash & 0x00FF00) | 0xFF003973);
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontSize: radius * 0.9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}