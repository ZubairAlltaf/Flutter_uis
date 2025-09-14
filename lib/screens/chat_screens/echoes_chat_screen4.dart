import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Ensure these paths are correct for your project structure
import '../../providers/chat_provider.dart';

// A seed for generating a consistent, winding path for the chat timeline.
final int _pathSeed = Random().nextInt(1000);

class EchoesChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const EchoesChatScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<EchoesChatScreen> createState() => _EchoesChatScreenState();
}

class _EchoesChatScreenState extends State<EchoesChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  Timer? _typingTimer;

  // Animation and interaction state
  late AnimationController _enterAnimationController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _enterAnimationController = AnimationController(vsync: this, duration: 800.ms);
    _bgAnimationController = AnimationController(vsync: this, duration: 30.seconds)..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _messageController.addListener(_onTextChanged);
      _chatProvider?.updateUserTypingStatus(widget.chatId, false);
      _enterAnimationController.forward();
      // Scroll to the bottom on initial load
      Timer(500.ms, () {
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
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    super.dispose();
  }

  void _onTextChanged() {
    if (_chatProvider == null || !mounted) return;
    _chatProvider!.updateUserTypingStatus(widget.chatId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _chatProvider!.updateUserTypingStatus(widget.chatId, false);
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatProvider?.user == null) return;
    final currentUser = _chatProvider!.user!;
    _messageController.clear();
    FocusScope.of(context).unfocus();
    _typingTimer?.cancel();
    _chatProvider!.updateUserTypingStatus(widget.chatId, false);
    final messageData = {
      'senderId': currentUser.uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'seed': Random().nextDouble(), // Unique seed for nebula shape
    };
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add(messageData);
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Animate to the new message
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
      backgroundColor: const Color(0xff020010),
      extendBodyBehindAppBar: true,
      // --- FIX IS HERE: The AppBar is now connected to the Scaffold ---
      appBar: _buildCelestialHeader(),
      body: Stack(
        children: [
          CosmicBackground(animation: _bgAnimationController),
          _buildMessagesCanvas(),
          Column(
            children: [
              const Spacer(),
              _buildSingularityInput(),
            ],
          ),
        ],
      ),
    );
  }

  // This method now correctly returns a PreferredSizeWidget for the AppBar
  PreferredSizeWidget _buildCelestialHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 10),
      child: Animate(
        controller: _enterAnimationController,
        effects: [
          FadeEffect(duration: 500.ms),
          SlideEffect(begin: const Offset(0, -0.5), curve: Curves.easeOutCubic),
        ],
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: const Color(0xff0d111c).withOpacity(0.5),
                border: Border(bottom: BorderSide(color: Colors.cyan.withOpacity(0.2))),
                boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 20, spreadRadius: -5)],
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
                      boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
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
                      style: GoogleFonts.exo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesCanvas() {
    final currentUserId = context.watch<ChatProvider>().user?.uid;
    return CustomPaint(
      painter: _CosmicRiverPainter(scrollController: _scrollController, pathSeed: _pathSeed),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final messages = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 100, bottom: 120, left: 20, right: 20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msgData = messages[index].data() as Map<String, dynamic>;
              final isMe = msgData['senderId'] == currentUserId;
              return _CelestialMessage(
                message: msgData,
                isMe: isMe,
                index: index,
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
        SlideEffect(begin: const Offset(0, 0.5), curve: Curves.easeOutCubic),
      ],
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
            decoration: BoxDecoration(
              color: const Color(0xff0d111c).withOpacity(0.7),
              border: Border(top: BorderSide(color: Colors.purple.withOpacity(0.2))),
              boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 20, spreadRadius: -5, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.exo(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Echo into the void...',
                      hintStyle: GoogleFonts.exo(color: Colors.white.withOpacity(0.4)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const Icon(Icons.send_rounded, color: Colors.white54, size: 26)
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(delay: 2.seconds, duration: 1.seconds, color: Colors.purple.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- All Custom Widgets & Painters ---

class _CelestialMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final int index;

  const _CelestialMessage({required this.message, required this.isMe, required this.index});

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final seed = (message['seed'] as double?) ?? 0.5;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _NebulaMessagePainter(
              isMe: isMe,
              seed: seed,
              animationValue: (sin(DateTime.now().millisecondsSinceEpoch / 2000.0 + seed * pi) + 1) / 2,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Text(
                message['content'] ?? '',
                style: GoogleFonts.exo(color: Colors.white, fontSize: 16, height: 1.4, shadows: [
                  const Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 1))
                ]),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 100.ms).slideX(
        begin: isMe ? 0.2 : -0.2,
        curve: Curves.easeOutQuart
    ).then().scaleXY(
        begin: 0.8,
        duration: 600.ms,
        curve: Curves.easeOutBack
    );
  }
}

class _NebulaMessagePainter extends CustomPainter {
  final bool isMe;
  final double seed;
  final double animationValue;

  _NebulaMessagePainter({required this.isMe, required this.seed, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((seed * 1000).toInt());
    final paint = Paint();
    final path = Path();
    final numPoints = 8;
    final angleStep = 2 * pi / numPoints;
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;

    path.moveTo(size.width / 2 + radiusX, size.height / 2);

    for (int i = 1; i <= numPoints; i++) {
      final angle = i * angleStep;
      final irregularity = (random.nextDouble() * 0.4 + 0.8);
      final x = size.width / 2 + cos(angle) * radiusX * irregularity;
      final y = size.height / 2 + sin(angle) * radiusY * irregularity;
      final controlPointVariance = 0.4;
      final cp1x = size.width / 2 + cos(angle - angleStep / 2) * radiusX * (1 + controlPointVariance * (random.nextDouble() - 0.5));
      final cp1y = size.height / 2 + sin(angle - angleStep / 2) * radiusY * (1 + controlPointVariance * (random.nextDouble() - 0.5));
      final cp2x = size.width / 2 + cos(angle - angleStep / 2) * radiusX * (1 + controlPointVariance * (random.nextDouble() - 0.5));
      final cp2y = size.height / 2 + sin(angle - angleStep / 2) * radiusY * (1 + controlPointVariance * (random.nextDouble() - 0.5));
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
    }
    path.close();

    final coreColor1 = isMe ? const Color(0xFF3C1053) : const Color(0xFF003973);
    final coreColor2 = isMe ? const Color(0xFFAD5389) : const Color(0xFFE5E5BE);
    paint.shader = LinearGradient(
      colors: [coreColor1.withOpacity(0.3), coreColor2.withOpacity(0.2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);

    final glowColor = isMe ? Colors.purpleAccent : Colors.cyanAccent;
    final animatedGlow = Color.lerp(glowColor, Colors.white, animationValue)!;
    paint
      ..shader = null
      ..color = animatedGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + 2 * animationValue);
    canvas.drawPath(path, paint);

    paint
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NebulaMessagePainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

class _CosmicRiverPainter extends CustomPainter {
  final ScrollController scrollController;
  final int pathSeed;

  _CosmicRiverPainter({required this.scrollController, required this.pathSeed}) : super(repaint: scrollController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    final random = Random(pathSeed);
    final scrollOffset = scrollController.hasClients ? scrollController.offset : 0.0;
    final totalHeight = scrollController.hasClients ? scrollController.position.maxScrollExtent + size.height : size.height;
    final points = <Offset>[];
    final segments = 20;
    for (int i = 0; i <= segments; i++) {
      final y = (i / segments) * totalHeight;
      final x = size.width / 2 + sin(i * 0.5 + random.nextDouble()) * (size.width * 0.2);
      points.add(Offset(x, y - scrollOffset));
    }
    path.moveTo(points[0].dx, points[0].dy);
    for (int i=0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i+1];
      final midPoint = Offset((p1.dx + p2.dx)/2, (p1.dy + p2.dy)/2);
      path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
    }
    paint.style = PaintingStyle.stroke;
    paint.shader = LinearGradient(
        colors: [Colors.purpleAccent.withOpacity(0.8), Colors.cyanAccent.withOpacity(0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    ).createShader(Rect.fromLTWH(0,0,size.width, size.height));
    paint.strokeWidth = 60.0;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 30.0);
    canvas.drawPath(path, paint);
    paint.strokeWidth = 40.0;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CosmicBackground extends StatelessWidget {
  final Animation<double> animation;
  const CosmicBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: [Color(0xff1a1a3f), Color(0xff020010)],
            ),
          ),
        ),
        ...List.generate(50, (index) => Star(seed: index)),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = animation.value;
            return Stack(
              children: [
                _AetherBlob(
                  color: Colors.purple.withOpacity(0.1),
                  size: 500,
                  alignment: Alignment(lerpDouble(-1.5, 1.5, value)!, lerpDouble(-1.0, 1.0, value)!),
                ),
                _AetherBlob(
                  color: Colors.cyan.withOpacity(0.1),
                  size: 400,
                  alignment: Alignment(lerpDouble(1.5, -1.5, value)!, lerpDouble(1.0, -1.0, value)!),
                ),
              ],
            );
          },
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
    _opacity = Random(widget.seed).nextDouble() * 0.5 + 0.2;
    _scheduleTwinkle();
  }

  void _scheduleTwinkle() {
    final random = Random(widget.seed + DateTime.now().microsecond);
    _duration = (random.nextInt(3000) + 1000).ms;
    _timer = Timer(_duration, () {
      if (mounted) {
        setState(() => _opacity = random.nextDouble() * 0.5 + 0.2);
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
    final size = random.nextDouble() * 2.0 + 0.5;
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
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(_opacity * 0.5), blurRadius: size * 2, spreadRadius: size * 0.5)],
        ),
      ),
    );
  }
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
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(decoration: const BoxDecoration(shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

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
    final color1 = Color((hash & 0xFF0000) | 0xFF301050);
    final color2 = Color((hash & 0x00FF00) | 0xFF003070);
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontSize: radius * 0.9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}