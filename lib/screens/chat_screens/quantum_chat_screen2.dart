import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/chat_provider.dart';

import '../homescreen/nexus_hub_screen2.dart';


class QuantumChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const QuantumChatScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<QuantumChatScreen> createState() => _QuantumChatScreenState();
}

class _QuantumChatScreenState extends State<QuantumChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _messageController.addListener(_onTextChanged);
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
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
    if (_chatProvider == null) return;
    _chatProvider!.updateUserTypingStatus(widget.chatId, true);
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatProvider!.updateUserTypingStatus(widget.chatId, false);
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
    };

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add(messageData);
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildHolographicAppBar(),
      body: Stack(
        children: [
          // The living, generative background
          Positioned.fill(child: EnergyWaveBackground(scrollController: _scrollController)),
          Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildDataStreamInput(),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildHolographicAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.25),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUser['name'] ?? 'Chat', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Connection: Stable', style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.white70), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessagesList() {
    final currentUserId = _chatProvider?.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Start a conversation/ Send a message.", style: TextStyle(color: Colors.white.withOpacity(0.5))));
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: EdgeInsets.only(top: 120, bottom: 20, left: 10, right: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msgData = messages[index].data() as Map<String, dynamic>;
            final isMe = msgData['senderId'] == currentUserId;

            // Date Divider Logic
            bool showDateDivider = false;
            if (index < messages.length - 1) {
              final prevMsgData = messages[index + 1].data() as Map<String, dynamic>;
              final currentDate = (msgData['timestamp'] as Timestamp?)?.toDate();
              final prevDate = (prevMsgData['timestamp'] as Timestamp?)?.toDate();
              if (currentDate != null && prevDate != null && currentDate.day != prevDate.day) {
                showDateDivider = true;
              }
            } else {
              showDateDivider = true;
            }

            return Column(
              children: [
                if (showDateDivider) _DateAnchor(timestamp: msgData['timestamp']),
                _MessageShard(message: msgData, isMe: isMe),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDataStreamInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
          color: Colors.black.withOpacity(0.4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'write anything...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan,
                    boxShadow: [
                      BoxShadow(color: Colors.cyanAccent.withOpacity(0.7), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black87, size: 24),
                ).animate(target: _messageController.text.isNotEmpty ? 1 : 0, onPlay: (c) => c.repeat(reverse: true))
                    .scale(end: const Offset(1.1, 1.1), duration: 500.ms)
                    .then()
                    .scale(end: const Offset(1/1.1, 1/1.1), duration: 500.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- The "Crystalline Shard" Message Widget ---
class _MessageShard extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageShard({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: CustomPaint(
        painter: _ShardPainter(isMe: isMe),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            message['content'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}

class _ShardPainter extends CustomPainter {
  final bool isMe;
  _ShardPainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isMe
            ? [const Color(0xff00a8cc), const Color(0xff039be5)]
            : [const Color(0xff5e35b1), const Color(0xff311b92)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isMe) {
      path.moveTo(0, 10);
      path.lineTo(size.width - 15, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - 15, size.height);
      path.lineTo(0, size.height - 10);
      path.close();
    } else {
      path.moveTo(size.width, 10);
      path.lineTo(15, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(15, size.height);
      path.lineTo(size.width, size.height - 10);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- The "Chronological Anchor" Date Divider ---
class _DateAnchor extends StatelessWidget {
  final Timestamp? timestamp;
  const _DateAnchor({this.timestamp});

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final date = ts.toDate();
    if (now.day == date.day && now.month == date.month && now.year == date.year) return 'Today';
    if (now.subtract(const Duration(days: 1)).day == date.day) return 'Yesterday';
    return DateFormat.yMMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(_formatDate(timestamp), style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    ).animate().fadeIn();
  }
}

// --- The "Living Energy Wave" Background ---
class EnergyWaveBackground extends StatefulWidget {
  final ScrollController scrollController;
  const EnergyWaveBackground({super.key, required this.scrollController});
  @override
  State<EnergyWaveBackground> createState() => _EnergyWaveBackgroundState();
}

class _EnergyWaveBackgroundState extends State<EnergyWaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    widget.scrollController.addListener(() {
      setState(() {
        _scrollOffset = widget.scrollController.offset;
      });
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
      builder: (context, child) {
        return CustomPaint(
          painter: EnergyWavePainter(_controller.value, _scrollOffset),
        );
      },
    );
  }
}

class EnergyWavePainter extends CustomPainter {
  final double time;
  final double scrollOffset;
  EnergyWavePainter(this.time, this.scrollOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff0a0a14), Color(0xff16213e)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final wavePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(-size.width, size.height * 0.5);
      for (double x = -size.width; x < size.width * 2; x++) {
        final y = size.height * 0.5 +
            sin((x / (size.width * 0.5)) + (time * 2 * 3.14) + (i * 0.5)) * 50 +
            cos((x / (size.width * 0.2)) + (time * 3 * 3.14) + (i * 1.5)) * 30 -
            (scrollOffset * 0.2);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}