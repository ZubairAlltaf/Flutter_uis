import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';

// Ensure these paths are correct for your project
import '../../widgets/user_search_delegate.dart';
import '../chat_screens/stellar_chat_screen3.dart';

class CelestialHubScreen extends StatelessWidget {
  const CelestialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final scrollController = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xff06080F), // A deeper, cosmic black
      drawer: CustomDrawer(chatProvider: chatProvider),
      body: Stack(
        children: [
          Positioned.fill(child: DataWeaveBackground(scrollController: scrollController)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, chatProvider),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: chatProvider.chats.isEmpty
                        ? _buildEmptyState()
                        : _buildDataWeaveList(chatProvider.chats, scrollController),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Text(
            'Neural Stream',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.cyan, blurRadius: 10)],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70, size: 28),
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate(chatProvider));
            },
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildDataWeaveList(List<Map<String, dynamic>> chats, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherUser = chat['otherUser'] as Map<String, dynamic>;
        // Alternate alignment for the weave effect
        final isRightAligned = index.isOdd;

        return _WovenNodeTile(
          key: ValueKey(chat['chatId']),
          chat: chat,
          isRightAligned: isRightAligned,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StellarChatScreen(
                  chatId: chat['chatId'],
                  otherUser: otherUser,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_rounded, color: Colors.cyanAccent, size: 90),
          const SizedBox(height: 20),
          const Text('The Stream is Dormant', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 10),
          Text("Search to form a new neural link.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

// --- The NEW Woven Node Tile ---
class _WovenNodeTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final bool isRightAligned;
  final VoidCallback onTap;

  const _WovenNodeTile({
    super.key,
    required this.chat,
    required this.isRightAligned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typingUsers = (chat['typing'] as List? ?? []);
    final currentUserId = Provider.of<ChatProvider>(context, listen: false).user?.uid;
    final isOtherUserTyping = typingUsers.isNotEmpty && !typingUsers.contains(currentUserId);
    final otherUser = chat['otherUser'] as Map<String, dynamic>;

    final tileContent = GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AvatarWithFallback(
                      imageUrl: otherUser['avatar'],
                      name: otherUser['name'],
                      radius: 28,
                    ),
                    if (isOtherUserTyping)
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.cyanAccent, width: 2)
                        ),
                      ).animate(onPlay: (c)=>c.repeat()).rotate(duration: 2.seconds).fadeIn(),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        otherUser['name'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOtherUserTyping ? 'streaming...' : (chat['lastMessage'] ?? '...'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isOtherUserTyping ? Colors.cyanAccent : Colors.white60,
                          fontSize: 13,
                          fontStyle: isOtherUserTyping ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10),
      child: CustomPaint(
        // The Connector is now part of the tile's background paint
        painter: _ConnectorPainter(isRightAligned: isRightAligned),
        child: Align(
          alignment: isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
          child: tileContent,
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 100.ms)
        .slideX(begin: isRightAligned ? 0.5 : -0.5, curve: Curves.easeOutCubic);
  }
}

class _ConnectorPainter extends CustomPainter {
  final bool isRightAligned;
  _ConnectorPainter({required this.isRightAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyan.withOpacity(0.6), Colors.cyan.withOpacity(0.1)],
        begin: isRightAligned ? Alignment.centerLeft : Alignment.centerRight,
        end: isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    double startX = size.width / 2;
    double startY = size.height / 2;

    double endX = isRightAligned ? size.width * 0.4 : size.width * 0.6;
    double endY = size.height / 2;

    double ctrlX1 = size.width / 2;
    double ctrlY1 = 0;

    double ctrlX2 = isRightAligned ? size.width * 0.6 : size.width * 0.4;
    double ctrlY2 = size.height;

    path.moveTo(startX, startY);
    path.cubicTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// --- The NEW Data Weave Background ---
class DataWeaveBackground extends StatefulWidget {
  final ScrollController scrollController;
  const DataWeaveBackground({super.key, required this.scrollController});
  @override
  State<DataWeaveBackground> createState() => _DataWeaveBackgroundState();
}

class _DataWeaveBackgroundState extends State<DataWeaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    widget.scrollController.addListener(() {
      if(mounted) {
        setState(() => _scrollOffset = widget.scrollController.offset);
      }
    });
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
      builder: (context, child) => CustomPaint(painter: DataWeavePainter(time: _controller.value, scrollOffset: _scrollOffset)),
    );
  }
}

class DataWeavePainter extends CustomPainter {
  final double time;
  final double scrollOffset;
  DataWeavePainter({required this.time, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xff06080F), BlendMode.src);

    // Central Spine
    final spinePaint = Paint()
      ..shader = LinearGradient(
          colors: [Colors.cyan.withOpacity(0), Colors.cyanAccent.withOpacity(0.5), Colors.cyan.withOpacity(0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter
      ).createShader(Rect.fromLTWH(size.width/2 - 2, 0, 4, size.height));
    canvas.drawRect(Rect.fromLTWH(size.width/2 - 2, 0, 4, size.height), spinePaint);

    final random = Random(5);
    for (int i = 0; i < 15; i++) {
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(0.1 + random.nextDouble() * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final path = Path();
      double yOffset = -scrollOffset + (size.height * 2 * ((time + random.nextDouble() * 2) % 1.0)) - size.height;
      double amplitude = size.width * 0.4 * (0.5 + random.nextDouble() * 0.5);
      double frequency = 0.5 + random.nextDouble() * 2;

      path.moveTo(size.width / 2 + sin(yOffset / (200 / frequency)) * amplitude, yOffset);

      for (double y = yOffset; y < yOffset + size.height * 3; y++) {
        double x = size.width / 2 + sin((y / (200 / frequency)) + time * 2 * pi) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DataWeavePainter oldDelegate) => true;
}

// --- SELF-CONTAINED: Intelligent Avatar with Fallback (Unchanged) ---
class AvatarWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;

  const AvatarWithFallback({super.key, this.imageUrl, this.name, this.radius = 25});

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? 'A';
    bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasImage ? (_, __) {} : null,
      child: !hasImage ? _buildFallback(displayName) : null,
    );
  }

  Widget _buildFallback(String displayName) {
    final hash = displayName.hashCode;
    final color1 = Color((hash & 0xFF0000) | 0xFF0055AA);
    final color2 = Color((hash & 0x00FF00) | 0xFFAA0055);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.8), color2.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontSize: radius * 0.9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}