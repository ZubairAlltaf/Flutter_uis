import 'dart:async'; // <-- ADD THIS IMPORT for the Timer
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';

class MessagingScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const MessagingScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  Timer? _typingTimer; // <-- ADD THIS for managing typing status

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _messageController.addListener(_onTextChanged);

    // Stop typing when entering the screen
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel(); // <-- CANCEL the timer to prevent memory leaks
    // Ensure we mark the user as not typing when they leave
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    super.dispose();
  }

  // --- UPDATED: Re-implemented typing logic to live within the screen ---
  void _onTextChanged() {
    if (_chatProvider == null) return;
    // Instantly notify that the user is typing
    _chatProvider!.updateUserTypingStatus(widget.chatId, true);

    // Cancel any previous timer
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

    // Start a new timer. If the user stops typing for 2 seconds, update status.
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatProvider!.updateUserTypingStatus(widget.chatId, false);
    });
  }

  // --- UPDATED: Re-implemented send message logic to use direct Firestore calls ---
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatProvider?.user == null) return;

    final currentUser = _chatProvider!.user!;
    _messageController.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    // Stop the typing indicator immediately when a message is sent
    _typingTimer?.cancel();
    _chatProvider!.updateUserTypingStatus(widget.chatId, false);

    final messageData = {
      'senderId': currentUser.uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // 1. Add the new message to the 'messages' subcollection
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(messageData);

    // 2. Update the parent chat document with the last message and timestamp
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- All UI Widgets below this point remain unchanged as they define the design ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildCustomAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff16213e), Color(0xff0f3460)],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.2),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.otherUser['avatar'] ?? 'https://i.pravatar.cc/150?u=${widget.otherUser['id']}'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherUser['name'] ?? 'Chat',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Placeholder for online status
              const Text(
                'Online',
                style: TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.call, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessagesList() {
    final currentUserId = _chatProvider?.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("Be the first to say something!", style: TextStyle(color: Colors.white.withOpacity(0.7))),
          );
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 120, bottom: 20, left: 10, right: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final isMe = msg['senderId'] == currentUserId;
            return _MessageBubble(message: msg, isMe: isMe);
          },
        );
      },
    );
  }

  Widget _buildInputField() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
          color: Colors.black.withOpacity(0.3),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.cyan, Colors.blueAccent],
                    ),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                ).animate(target: _messageController.text.isNotEmpty ? 1 : 0).scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timestamp = message['timestamp'] as Timestamp?;
    final timeString = timestamp != null ? DateFormat.jm().format(timestamp.toDate()) : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(colors: [Color(0xff00a8cc), Color(0xff039be5)])
              : null,
          color: !isMe ? Colors.white.withOpacity(0.15) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['content'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: isMe ? 0.2 : -0.2, curve: Curves.easeOutCubic);
  }
}