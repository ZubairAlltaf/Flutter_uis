import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';

// Make sure these paths are correct for your project structure
import '../../providers/chat_provider.dart';
import '../../widgets/user_search_delegate.dart';
import '../chat_screens/quantum_chat_screen2.dart';

class NexusHubScreen extends StatelessWidget {
  const NexusHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0a0a14), // Darker, tech-focused background
      drawer: CustomDrawer(chatProvider: chatProvider),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [Color(0xff1a2333), Color(0xff0a0a14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildNexusHeader(context, chatProvider),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: chatProvider.chats.isEmpty
                      ? _buildEmptyNexus()
                      : _buildNexusConversations(context, chatProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNexusHeader(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
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
                  'NEXUS HUB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 28),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: UserSearchDelegate(chatProvider),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5, curve: Curves.easeOutCubic);
  }

  Widget _buildEmptyNexus() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, color: Color(0xff00a8cc), size: 90),
          const SizedBox(height: 20),
          const Text(
            'No Active Connections',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            "Use the search icon to establish a new link.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildNexusConversations(BuildContext context, ChatProvider chatProvider) {
    // This transform gives the list a 3D perspective effect
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.08),
      alignment: FractionalOffset.center,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chatProvider.chats.length,
        itemBuilder: (context, index) {
          final chat = chatProvider.chats[index];

          return _NexusDataShardTile(
            chat: chat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // NAVIGATES TO THE NEW, UNIQUE CHAT SCREEN
                  builder: (context) => QuantumChatScreen(
                    chatId: chat['chatId'],
                    otherUser: chat['otherUser'],
                  ),
                ),
              );
            },
          )
              .animate()
              .fadeIn(duration: 700.ms, delay: (150 * index).ms)
              .slideX(begin: -0.5, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

// --- The NEW "Data Shard" Conversation Tile ---

class _NexusDataShardTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const _NexusDataShardTile({
    required this.chat,
    required this.onTap,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    if (now.difference(date).inDays == 0) return DateFormat.jm().format(date);
    if (now.difference(date).inDays == 1) return 'Yesterday';
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final typingUsers = (chat['typing'] as List? ?? []);
    final currentUserId = Provider.of<ChatProvider>(context, listen: false).user?.uid;
    final isOtherUserTyping = typingUsers.isNotEmpty && !typingUsers.contains(currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _ShardPainter(),
          child: Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildHexagonAvatar(chat['otherUser']['avatar'], chat['otherUser']['id']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat['otherUser']['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      isOtherUserTyping
                          ? const GlitchyTypingIndicator()
                          : Text(
                        chat['lastMessage'] ?? 'No messages yet.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _formatTimestamp(chat['timestamp']),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHexagonAvatar(String? avatarUrl, String? userId) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatarUrl ?? 'https://i.pravatar.cc/150?u=$userId'),
          ),
        ),
      ),
    );
  }
}

class GlitchyTypingIndicator extends StatelessWidget {
  const GlitchyTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'transmitting...',
      style: TextStyle(
        color: Colors.cyanAccent.withOpacity(0.9),
        fontStyle: FontStyle.italic,
        fontSize: 14,
        shadows: const [
          Shadow(color: Colors.cyanAccent, blurRadius: 3),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shakeX(hz: 5, amount: 0.8, duration: 1500.ms)
        .then(delay: 1.seconds)
        .fadeOut(duration: 100.ms)
        .then()
        .fadeIn(duration: 100.ms);
  }
}

class _ShardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyan.withOpacity(0.5), Colors.blue.withOpacity(0.2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, 15);
    path.lineTo(15, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 15);
    path.lineTo(size.width - 15, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0);
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}