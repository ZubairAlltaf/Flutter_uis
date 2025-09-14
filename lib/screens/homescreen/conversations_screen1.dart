import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';

// Make sure these paths are correct for your project structure
import '../../widgets/user_search_delegate.dart';
import '../chat_screens/messaging_screen1.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff101018), // A deeper space black
      drawer: CustomDrawer(chatProvider: chatProvider),
      body: Container(
        // A more subtle, radial gradient for an ambient feel
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1, -1),
            radius: 1.5,
            colors: [Color(0xff16213e), Color(0xff101018)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, chatProvider),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: chatProvider.chats.isEmpty
                      ? _buildEmptyState()
                      : _buildConversationsList(context, chatProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.sort_rounded, color: Colors.white70, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Text(
            'Chats',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins', // Example of using a custom font for style
                letterSpacing: 1.1),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 30),
            onPressed: () {
              // THIS IS NOW FUNCTIONAL
              showSearch(
                context: context,
                delegate: UserSearchDelegate(chatProvider),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, curve: Curves.easeOut);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xff00a8cc), size: 80),
          const SizedBox(height: 20),
          const Text(
            'Your conversations live here',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            "Find people to chat with using the search icon.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildConversationsList(BuildContext context, ChatProvider chatProvider) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        final bool isOnline = index % 3 == 0; // Placeholder for online status

        return _AuroraConversationTile( // Using the new, unique tile
          chat: chat,
          isOnline: isOnline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagingScreen(
                  chatId: chat['chatId'],
                  otherUser: chat['otherUser'],
                ),
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: (150 * index).ms)
            .slideY(begin: 0.3, curve: Curves.easeOutCubic);
      },
    );
  }
}


// --- The NEW High-Level, Unique Conversation Tile ---

class _AuroraConversationTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final bool isOnline;
  final VoidCallback onTap;

  const _AuroraConversationTile({
    required this.chat,
    required this.isOnline,
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
      padding: const EdgeInsets.only(bottom: 25.0),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --- The main card with gradient border and glass effect ---
              Positioned(
                left: 25,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(1.5), // Border width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [Colors.cyan.withOpacity(0.5), Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(45, 12, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: _buildCardContent(isOtherUserTyping),
                      ),
                    ),
                  ),
                ),
              ),
              // --- The overlapping avatar ---
              Positioned(
                left: 0,
                top: -10,
                child: _buildAvatarWithPulse(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(bool isTyping) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chat['otherUser']['name'] ?? 'Unknown User',
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              isTyping
                  ? Text(
                'typing...',
                style: TextStyle(color: Colors.cyanAccent.withOpacity(0.9), fontStyle: FontStyle.italic, fontSize: 14),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3))
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
        // --- Timestamp (Unread count is removed) ---
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            _formatTimestamp(chat['timestamp']),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithPulse() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isOnline)
        // Pulsing glow effect for online status
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
            duration: 2.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            curve: Curves.easeOut,
          )
              .blurXY(end: 12),
        // The main avatar
        CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xff101018), // Match the main background
          child: CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(chat['otherUser']['avatar'] ?? 'https://i.pravatar.cc/150?u=${chat['otherUser']['id']}'),
          ),
        ),
      ],
    );
  }
}