import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // <-- ADD THIS IMPORT
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import 'package:flutteruis/widgets/custom_drawer.dart';

import '../chat_screens/chat_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(chatProvider),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(chatProvider: chatProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan.shade300, Colors.blue.shade900],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: _buildChatList(context, chatProvider),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, ChatProvider chatProvider) {
    if (chatProvider.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_rounded, color: Colors.white.withOpacity(0.5), size: 60),
            const SizedBox(height: 16),
            Text(
              'No chats yet.',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the search icon to find someone to talk to.",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    }

    // This builder now handles the logic for showing the typing indicator
    return ListView.builder(
      key: ValueKey(chatProvider.uiStyle),
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        final typingUsers = (chat['typing'] as List? ?? []);
        final isOtherUserTyping = typingUsers.isNotEmpty && !typingUsers.contains(chatProvider.user?.uid);

        // This widget dynamically changes between the last message and a "typing..." indicator
        final subtitleWidget = isOtherUserTyping
            ? Text(
          'typing...',
          style: TextStyle(color: Colors.cyanAccent.withOpacity(0.9), fontStyle: FontStyle.italic),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3))
            : Text(
          chat['lastMessage'] ?? '',
          style: const TextStyle(color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

        switch (chatProvider.uiStyle) {
          case ChatUIStyle.minimalistic:
            return _buildMinimalisticTile(context, chat, subtitleWidget);
          case ChatUIStyle.cardBased:
            return _buildCardBasedTile(context, chat, subtitleWidget);
          case ChatUIStyle.bubble:
            return _buildBubbleTile(context, chat, subtitleWidget);
        }
      },
    );
  }

  // --- NEW: Helper method to navigate to the chat screen ---
  void _navigateToChat(BuildContext context, Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chat['chatId'], otherUser: chat['otherUser']),
      ),
    );
  }

  // --- NEW: Extracted widgets for each style for better readability ---
  Widget _buildMinimalisticTile(BuildContext context, Map<String, dynamic> chat, Widget subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat['otherUser']['avatar'] ?? 'https://via.placeholder.com/50'),
      ),
      title: Text(chat['otherUser']['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: subtitle,
      trailing: Text(
        _formatTimestamp(chat['timestamp']),
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      onTap: () => _navigateToChat(context, chat),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildCardBasedTile(BuildContext context, Map<String, dynamic> chat, Widget subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyan.withOpacity(0.4), width: 1.5),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chat['otherUser']['avatar'] ?? 'https://via.placeholder.com/50'),
              ),
              title: Text(chat['otherUser']['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: subtitle,
              trailing: Text(
                _formatTimestamp(chat['timestamp']),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              onTap: () => _navigateToChat(context, chat),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut);
  }

  Widget _buildBubbleTile(BuildContext context, Map<String, dynamic> chat, Widget subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(0.4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['otherUser']['avatar'] ?? 'https://via.placeholder.com/50'),
          ),
          title: Text(chat['otherUser']['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: subtitle,
          trailing: Text(
            _formatTimestamp(chat['timestamp']),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () => _navigateToChat(context, chat),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.elasticOut, begin: const Offset(0.9, 0.9));
  }

  // --- UPDATED: Intelligent Timestamp Formatting ---
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();

    final startOfNow = DateTime(now.year, now.month, now.day);
    final startOfDate = DateTime(date.year, date.month, date.day);
    final difference = startOfNow.difference(startOfDate);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date); // e.g., 5:34 PM
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.yMd().format(date); // e.g., 8/25/2025
    }
  }
}


// --- UPDATED: Search Delegate with Debouncing for Efficiency ---
class UserSearchDelegate extends SearchDelegate {
  final ChatProvider chatProvider;
  Timer? _debounce;

  UserSearchDelegate(this.chatProvider) {
    // Clear previous search results when opening the search delegate
    chatProvider.searchUsers('');
  }

  // --- NEW: Dispose timer to prevent memory leaks ---
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20)
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white), // For the query text
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          chatProvider.searchUsers('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: Colors.blue.shade800,
      child: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (query.isEmpty) {
            return const Center(child: Text('Search for users by their email.', style: TextStyle(color: Colors.white70)));
          }
          if (provider.searchResults.isEmpty) {
            return const Center(child: Text('No users found.', style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final user = provider.searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['avatar'] ?? 'https://via.placeholder.com/50'),
                ),
                title: Text(user['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                subtitle: Text(user['email'] ?? '', style: const TextStyle(color: Colors.white70)),
                onTap: () async {
                  final chatId = await chatProvider.initiateChat(user['id']);
                  if (chatId != null && context.mounted) {
                    // Close the search screen first for a cleaner navigation flow
                    close(context, null);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chatId, otherUser: user),
                      ),
                    );
                  } else if (context.mounted) {
                    chatProvider.showSnackBar(context, 'Failed to start chat', isError: true);
                  }
                },
              ).animate().fadeIn(duration: 300.ms);
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // --- UPDATED: This now handles the debouncing logic ---
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        chatProvider.searchUsers(query);
      } else {
        chatProvider.searchUsers('');
      }
    });

    return buildResults(context);
  }
}