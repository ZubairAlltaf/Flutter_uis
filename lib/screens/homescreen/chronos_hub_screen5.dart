import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/chat_provider.dart';
import '../../widgets/user_search_delegate.dart';
import '../chat_screens/event_horizon_chat_screen5.dart';

class AetheriumHubScreen extends StatefulWidget {
  const AetheriumHubScreen({super.key});

  @override
  State<AetheriumHubScreen> createState() => _AetheriumHubScreenState();
}

class _AetheriumHubScreenState extends State<AetheriumHubScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xff000005),
      body: Stack(
        children: [
          const QuantumFoamBackground(),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 80, bottom: 50),
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                return _QuantumEchoTile(
                  key: ValueKey(chat['chatId']),
                  chat: chat,
                  isEven: index.isEven,
                  onTap: () {
                    Navigator.push(context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => EventHorizonChatScreen(
                            chatId: chat['chatId'], otherUser: chat['otherUser'],
                          ),
                          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                        )
                    );
                  },
                );
              },
            ),
          ),
          _buildHUD(),
          if (chatProvider.chats.isEmpty) _buildEmptyState(),
        ],
      ),
      drawer: CustomDrawer(chatProvider: chatProvider),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.cyan.withOpacity(0.3))
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 20), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
              const SizedBox(width: 16),
              Text('AETHERIUM', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 10)])),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20), onPressed: () => showSearch(context: context, delegate: UserSearchDelegate(Provider.of<ChatProvider>(context, listen: false)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stream, color: Color(0xfff02c84), size: 90),
          const SizedBox(height: 20),
          Text('Timeline Empty', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text("Create a new echo via the search glyph.", style: GoogleFonts.exo(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ],
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

// --- The Quantum Echo Tile (a single chat) ---
class _QuantumEchoTile extends StatefulWidget {
  final Map<String, dynamic> chat;
  final bool isEven;
  final VoidCallback onTap;

  const _QuantumEchoTile({super.key, required this.chat, required this.isEven, required this.onTap});

  @override
  State<_QuantumEchoTile> createState() => _QuantumEchoTileState();
}

class _QuantumEchoTileState extends State<_QuantumEchoTile> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: 2.seconds)..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.chat['otherUser']['name'] ?? 'Unknown';
    final typingUsers = (widget.chat['typing'] as List? ?? []);
    final currentUserId = Provider.of<ChatProvider>(context, listen: false).user?.uid;
    final isTyping = typingUsers.isNotEmpty && !typingUsers.contains(currentUserId);
    final timestamp = widget.chat['timestamp'] as Timestamp?;

    return Align(
      alignment: widget.isEven ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          width: MediaQuery.of(context).size.width * 0.7,
          child: CustomPaint(
            painter: _TetherPainter(
              isEven: widget.isEven,
              isTyping: isTyping,
              animation: _animationController,
            ),
            child: Row(
              mainAxisAlignment: widget.isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (!widget.isEven) _buildInfoText(name, isTyping, timestamp, CrossAxisAlignment.end),
                _NodeVisual(
                  seed: name.hashCode,
                  isTyping: isTyping,
                  avatarUrl: widget.chat['otherUser']['avatar'],
                  name: name,
                  animation: _animationController,
                ),
                if (widget.isEven) _buildInfoText(name, isTyping, timestamp, CrossAxisAlignment.start),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideX(begin: widget.isEven ? -0.5 : 0.5, curve: Curves.easeOutQuart);
  }

  Widget _buildInfoText(String name, bool isTyping, Timestamp? timestamp, CrossAxisAlignment align) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: align,
          children: [
            Text(name, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: align == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right),
            const SizedBox(height: 4),
            Text(
              isTyping ? '...' : (widget.chat['lastMessage'] ?? '...'),
              style: GoogleFonts.exo(color: Colors.white70, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: align == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right,
            ).animate(target: isTyping ? 1 : 0).shimmer(duration: 1.seconds, color: Colors.cyanAccent),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(DateFormat.jm().format(timestamp.toDate()), style: GoogleFonts.exo(color: Colors.white38, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}

// --- The Visual part of the node ---
class _NodeVisual extends StatelessWidget {
  final int seed;
  final bool isTyping;
  final String? avatarUrl;
  final String name;
  final Animation<double> animation;

  const _NodeVisual({required this.seed, required this.isTyping, this.avatarUrl, required this.name, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: CustomPaint(
        painter: _NodePainter(seed: seed, isTyping: isTyping, animation: animation),
        child: Center(
          child: AvatarWithFallback(
            imageUrl: avatarUrl, name: name, radius: 26,
          ),
        ),
      ),
    );
  }
}

// --- Painter for the Node's rings and atmosphere ---
class _NodePainter extends CustomPainter {
  final int seed;
  final bool isTyping;
  final Animation<double> animation;

  _NodePainter({required this.seed, required this.isTyping, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 * 0.7;
    final random = math.Random(seed);

    final color = HSLColor.fromAHSL(1, (seed % 360).toDouble(), 0.7, 0.6).toColor();
    final animValue = animation.value;

    final ringPaint = Paint()..style = PaintingStyle.stroke;
    final hazePaint = Paint();

    // Outer atmosphere
    final double hazeRadius = isTyping ? radius * 1.3 : radius * 1.1;
    final double hazeBlur = isTyping ? 15.0 + 10 * (math.sin(animValue * math.pi * 4) + 1) : 8.0;
    hazePaint.shader = ui.Gradient.radial(center, hazeRadius, [
      (isTyping ? Colors.cyanAccent : color).withOpacity(0.5),
      (isTyping ? Colors.cyanAccent : color).withOpacity(0.0),
    ]);
    hazePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, hazeBlur);
    canvas.drawCircle(center, hazeRadius, hazePaint);

    // Rotating Rings
    for (int i = 1; i <= 2; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(animValue * 2 * math.pi * (i.isEven ? 1 : -1) * 0.5);
      canvas.translate(-center.dx, -center.dy);

      ringPaint.strokeWidth = 1.0 + random.nextDouble() * 1.5;
      ringPaint.color = Colors.white.withOpacity(0.2 + random.nextDouble() * 0.3);
      canvas.drawCircle(center, radius + 8 * i, ringPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NodePainter oldDelegate) => isTyping != oldDelegate.isTyping;
}

// --- Painter for the Timeline Tether ---
class _TetherPainter extends CustomPainter {
  final bool isEven;
  final bool isTyping;
  final Animation<double> animation;

  _TetherPainter({required this.isEven, required this.isTyping, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final nodeCenter = Offset(isEven ? 40 : size.width - 40, size.height / 2);
    final timelineX = size.width / 2;

    final paint = Paint()..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(timelineX, nodeCenter.dy);
    path.cubicTo(timelineX, nodeCenter.dy, (timelineX + nodeCenter.dx)/2, nodeCenter.dy, nodeCenter.dx, nodeCenter.dy);

    paint
      ..color = Colors.cyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    if (isTyping) {
      final metrics = path.computeMetrics().first;
      final pulseOffset = metrics.length * (animation.value % 1.0);
      final tangent = metrics.getTangentForOffset(pulseOffset);
      if (tangent != null) {
        final pulsePaint = Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.drawCircle(tangent.position, 5.0, pulsePaint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _TetherPainter oldDelegate) => isTyping != oldDelegate.isTyping;
}


// --- Painter for the Central Timeline ---
class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final paint = Paint();
    final rect = Rect.fromLTWH(center - 1.5, 0, 3, size.height);

    paint.shader = ui.Gradient.linear(
        Offset(center, 0), Offset(center, size.height),
        [const Color(0xfff02c84).withOpacity(0.8), Colors.cyan.withOpacity(0.8)]
    );
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawRect(rect, paint);

    paint.shader = null;
    paint.maskFilter = null;
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawRect(Rect.fromLTWH(center - 0.5, 0, 1, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// --- New Animated Background ---
class QuantumFoamBackground extends StatefulWidget {
  const QuantumFoamBackground({super.key});
  @override
  State<QuantumFoamBackground> createState() => _QuantumFoamBackgroundState();
}
class _QuantumFoamBackgroundState extends State<QuantumFoamBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final int _particleCount = 200;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 20.seconds)..repeat();
    _particles = List.generate(_particleCount, (index) => _Particle(seed: index));
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
        for (var p in _particles) { p.update(); }
        return CustomPaint(
          painter: _QuantumFoamPainter(particles: _particles),
          child: Container(),
        );
      },
    );
  }
}

class _Particle {
  late double x, y, size, opacity, speed;
  final math.Random random;
  _Particle({required int seed}) : random = math.Random(seed) {
    reset();
  }
  void reset() {
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 1.5 + 0.5;
    opacity = random.nextDouble() * 0.1 + 0.05;
    speed = random.nextDouble() * 0.0005;
  }
  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = random.nextDouble();
    }
  }
}
class _QuantumFoamPainter extends CustomPainter {
  final List<_Particle> particles;
  _QuantumFoamPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- Avatar Widget (Unchanged) ---
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
      backgroundColor: const Color(0xff1e1e32),
      child: ClipOval(
        child: hasValidImage
            ? Image.network(
          imageUrl!, width: radius * 2, height: radius * 2, fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildFallback(displayName),
          loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
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