import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const ChatScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  ChatProvider? _chatProvider;

  // REMOVED: All old pagination variables (_messages, _isInitialLoading, etc.)
  // The StreamBuilder is now the single source of truth for our messages.

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _messageController.addListener(_onTextChanged);

    // We don't need to fetch messages here anymore, the StreamBuilder does it.
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    super.dispose();
  }

  void _onTextChanged() {
    // This logic for the typing indicator remains the same and is correct.
    _chatProvider?.updateUserTypingStatus(widget.chatId, true);
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    });
  }

  // REMOVED: All old fetch methods (_fetchInitialMessages, _fetchMoreMessages, _scrollListener)
  // They are no longer needed because the StreamBuilder handles everything.

  @override
  Widget build(BuildContext context) {
    final user = _chatProvider?.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan.shade300, Colors.blue.shade900],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              // SIMPLIFIED: The body is now just the StreamBuilder.
              child: _buildMessagesList(user),
            ),
            _buildInputField(user),
          ],
        ),
      ),
    );
  }

  // This widget now contains the StreamBuilder for a truly realtime experience.
  Widget _buildMessagesList(User? user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(), // .snapshots() provides the realtime stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Say hello!",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
          );
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // This keeps the list scrolled to the bottom
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final isMe = messageData['senderId'] == user?.uid;

            // Logic to decide if a date divider should be shown
            bool showDateDivider = false;
            if (index < messages.length - 1) {
              final previousMessageData = messages[index + 1].data() as Map<String, dynamic>;
              final currentDate = (messageData['timestamp'] as Timestamp?)?.toDate();
              final previousDate = (previousMessageData['timestamp'] as Timestamp?)?.toDate();
              if (currentDate != null && previousDate != null && currentDate.day != previousDate.day) {
                showDateDivider = true;
              }
            } else {
              // Always show date for the very first message in the chat
              showDateDivider = true;
            }

            return Column(
              children: [
                if (showDateDivider)
                  _buildDateDivider(messageData['timestamp']),
                _buildMessageBubble(messageData, isMe, _chatProvider!.uiStyle),
              ],
            );
          },
        );
      },
    );
  }

  // SIMPLIFIED: _sendMessage now ONLY writes to Firestore.
  // The StreamBuilder will automatically handle updating the UI. NO MORE CRASHES.
  Future<void> _sendMessage(User? user) async {
    final content = _messageController.text.trim();
    if (content.isNotEmpty && user != null) {
      final messageContent = _messageController.text;
      _messageController.clear(); // Clear the text field immediately

      _typingTimer?.cancel();
      _chatProvider?.updateUserTypingStatus(widget.chatId, false);

      final messageData = {
        'senderId': user.uid,
        'content': messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // 1. Add the message to the database.
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      // 2. Update the last message for the main chat list.
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // NO MORE setState or local list manipulation is needed!
    }
  }

  // --- Helper Widgets for UI (Unchanged) ---
  String _formatDateDivider(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final startOfNow = DateTime(now.year, now.month, now.day);
    final startOfDate = DateTime(date.year, date.month, date.day);
    final difference = startOfNow.difference(startOfDate);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';

    return DateFormat.yMMMMd().format(date);
  }

  Widget _buildDateDivider(Timestamp? timestamp) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDateDivider(timestamp),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInputField(User? user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(user),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _sendMessage(user),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.send, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, ChatUIStyle style) {
    final textWidget = Text(
      message['content'] ?? '',
      style: const TextStyle(color: Colors.white),
    );

    switch (style) {
      case ChatUIStyle.minimalistic:
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue.shade900 : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: textWidget,
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: isMe ? 0.2 : -0.2);

      case ChatUIStyle.cardBased:
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isMe ? Colors.blue.shade900 : Colors.grey.shade800).withOpacity(0.3),
                    border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: textWidget,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale();

      case ChatUIStyle.bubble:
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.blue.shade900.withOpacity(0.7)
                  : Colors.grey.shade800.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: textWidget,
          ),
        ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.bounceIn);
    }
  }
}