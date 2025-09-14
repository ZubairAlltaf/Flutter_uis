import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Make sure these paths are correct for your project structure
import '../../providers/chat_provider.dart';
import '../../widgets/user_search_delegate.dart';
import '../chat_screens/echoes_chat_screen4.dart'; // Ensure this matches your chat screen file name

class ChronosHubScreen extends StatefulWidget {
  const ChronosHubScreen({super.key});

  @override
  State<ChronosHubScreen> createState() => _ChronosHubScreenState();
}

class _ChronosHubScreenState extends State<ChronosHubScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff020414),
      drawer: CustomDrawer(chatProvider: chatProvider),
      body: Stack(
        children: [
          AuroraBackground(scrollController: _scrollController),
          SafeArea(
            child: Column(
              children: [
                _buildChronosHeader(context, chatProvider),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: chatProvider.chats.isEmpty
                        ? _buildEmptyState()
                        : _buildConversationCascade(chatProvider.chats),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronosHeader(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
            'CHRONOS',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 28),
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate(chatProvider));
            },
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_empty_rounded, color: Color(0xffa88dff), size: 90),
        const SizedBox(height: 20),
        const Text(
          'No Timestreams Active',
          style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Text("Search to create a new echo.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
      ],
    ).animate().fadeIn(delay: 200.ms).scale();
  }

  Widget _buildConversationCascade(List<Map<String, dynamic>> chats) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final chat = chats[index];
                final isStaggered = index.isEven;
                return Padding(
                  padding: EdgeInsets.only(bottom: 20, left: isStaggered ? 0 : 40, right: isStaggered ? 40 : 0),
                  child: _TimeCrystalTile(
                    chat: chat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EchoesChatScreen(
                            chatId: chat['chatId'],
                            otherUser: chat['otherUser'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: chats.length,
            ),
          ),
        ),
      ],
    );
  }
}

// --- The NEW Time Crystal Tile ---
class _TimeCrystalTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const _TimeCrystalTile({required this.chat, required this.onTap});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    if (now.difference(date).inDays == 0) return DateFormat.jm().format(date);
    return 'Yesterday';
  }

  @override
  Widget build(BuildContext context) {
    final typingUsers = (chat['typing'] as List? ?? []);
    final currentUserId = Provider.of<ChatProvider>(context, listen: false).user?.uid;
    final isOtherUserTyping = typingUsers.isNotEmpty && !typingUsers.contains(currentUserId);

    Widget crystalContent = GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _CrystalPainter(isTyping: isOtherUserTyping),
        child: ClipPath(
          clipper: _CrystalClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(chat['otherUser']['avatar'] ?? 'https://i.pravatar.cc/150?u=${chat['otherUser']['id']}'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          chat['otherUser']['name'] ?? 'Unknown User',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          chat['lastMessage'] ?? '...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimestamp(chat['timestamp']),
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if(isOtherUserTyping) {
      crystalContent = crystalContent.animate(onPlay: (c)=>c.repeat(reverse: true))
          .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.5));
    }

    return crystalContent.animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutCubic)
        .move(begin: const Offset(0, 50), curve: Curves.easeOutCubic);
  }
}

class _CrystalPainter extends CustomPainter {
  final bool isTyping;
  _CrystalPainter({required this.isTyping});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isTyping ? 3.0 : 1.5
      ..shader = LinearGradient(
        colors: isTyping
            ? [Colors.white, const Color(0xffa88dff)]
            : [const Color(0xffa88dff).withOpacity(0.8), Colors.cyan.withOpacity(0.5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isTyping ? 6.0 : 3.0);

    final path = _CrystalClipper().getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CrystalPainter oldDelegate) => isTyping != oldDelegate.isTyping;
}

class _CrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(0, size.height * 0.75);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- Parallax Background ---
class AuroraBackground extends StatefulWidget {
  final ScrollController scrollController;
  const AuroraBackground({super.key, required this.scrollController});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> {
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if(mounted) {
        setState(() => _scrollOffset = widget.scrollController.offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -_scrollOffset * 0.3), // Parallax effect
      child: Stack(
        children: [
          _buildBlob(color: const Color(0xffa88dff), alignment: const Alignment(-1.5, -1.0)),
          _buildBlob(color: const Color(0xff6441a5), alignment: const Alignment(1.5, 1.0)),
          _buildBlob(color: Colors.cyan, alignment: const Alignment(0, 0.2)),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob({required Color color, required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .move(duration: 20.seconds, begin: const Offset(-50, -50), end: const Offset(50, 50))
          .then()
          .rotate(duration: 15.seconds, begin: 0, end: 0.2),
    );
  }
}