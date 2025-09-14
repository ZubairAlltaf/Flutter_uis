import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class StellarChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const StellarChatScreen({
    required this.chatId,
    required this.otherUser,
    super.key,
  });

  @override
  State<StellarChatScreen> createState() => _StellarChatScreenState();
}

class _StellarChatScreenState extends State<StellarChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _messageController.addListener(_onTextChanged);
      _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _chatProvider?.updateUserTypingStatus(widget.chatId, false);
    super.dispose();
  }

  void _onTextChanged() {
    if (_chatProvider == null || !mounted) return;
    _chatProvider!.updateUserTypingStatus(widget.chatId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _chatProvider!.updateUserTypingStatus(widget.chatId, false);
      }
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
      backgroundColor: const Color(0xff00001a),
      appBar: _buildAetheriumHeader(),
      body: Stack(
        children: [
          AetheriumBackground(scrollController: _scrollController),
          Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildCommandInputBar(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAetheriumHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff00001a).withOpacity(0.5),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CustomPaint(
              painter: _HexagonFramePainter(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AvatarWithFallback(
                    imageUrl: widget.otherUser['avatar'],
                    name: widget.otherUser['name'],
                    radius: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.otherUser['name'] ?? 'Chat',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                    overflow: TextOverflow.ellipsis,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final chatData = snapshot.data!.data() as Map<String, dynamic>?;
                      final typingUsers = (chatData?['typing'] as List? ?? []);
                      final isTyping = typingUsers.isNotEmpty && !typingUsers.contains(_chatProvider?.user?.uid);
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isTyping ? 'Transmitting...' : 'Aether link stable',
                          key: ValueKey(isTyping),
                          style: TextStyle(
                              color: isTyping ? Colors.white : Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontStyle: isTyping ? FontStyle.italic : FontStyle.normal),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5),
    );
  }

  Widget _buildMessagesList() {
    final currentUserId = context.watch<ChatProvider>().user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("The Aether is silent.\nBegin the conversation.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5))));
        }
        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 120, bottom: 20, left: 10, right: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msgData = messages[index].data() as Map<String, dynamic>;
            final isMe = msgData['senderId'] == currentUserId;
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
                if (showDateDivider) _TimelineDivider(timestamp: msgData['timestamp']),
                _AetherialMessagePod(message: msgData, isMe: isMe),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCommandInputBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
          decoration: BoxDecoration(
            color: const Color(0xff00001a).withOpacity(0.7),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, child) {
                    final hasText = value.text.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasText ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: hasText ? Colors.white : Colors.white54),
                      ),
                      child: Icon(Icons.arrow_upward_rounded, color: hasText ? Colors.black : Colors.white54, size: 24),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- The NEW Aetherial Message Pod ---
class _AetherialMessagePod extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _AetherialMessagePod({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: CustomPaint(
          painter: _PodPainter(isMe: isMe),
          child: ClipPath(
            clipper: _PodClipper(isMe: isMe),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Text(
                  message['content'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
          .move(begin: const Offset(0, 50), curve: Curves.easeOutCubic),
    );
  }
}

class _PodPainter extends CustomPainter {
  final bool isMe;
  _PodPainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
          colors: isMe
              ? [Colors.cyan.withOpacity(0.8), Colors.blue.withOpacity(0.8)]
              : [Colors.purple.withOpacity(0.8), const Color(0xff9f5afd).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final path = _PodClipper(isMe: isMe).getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PodClipper extends CustomClipper<Path> {
  final bool isMe;
  _PodClipper({required this.isMe});

  @override
  Path getClip(Size size) {
    final path = Path();
    final tailSize = size.height * 0.4;
    final r = Radius.circular(size.height / 2.5);

    if (isMe) {
      path.moveTo(0, r.y);
      path.arcToPoint(Offset(r.x, 0), radius: r, clockwise: false);
      path.lineTo(size.width - r.x, 0);
      path.arcToPoint(Offset(size.width, r.y), radius: r, clockwise: false);
      path.lineTo(size.width, size.height - r.y);
      path.arcToPoint(Offset(size.width - r.x, size.height), radius: r, clockwise: false);
      path.lineTo(tailSize, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - tailSize);
      path.close();
    } else {
      path.moveTo(r.x, 0);
      path.lineTo(size.width - r.x, 0);
      path.arcToPoint(Offset(size.width, r.y), radius: r, clockwise: false);
      path.lineTo(size.width, size.height - tailSize);
      path.quadraticBezierTo(size.width, size.height, size.width - tailSize, size.height);
      path.lineTo(r.x, size.height);
      path.arcToPoint(Offset(0, size.height - r.y), radius: r, clockwise: false);
      path.lineTo(0, r.y);
      path.arcToPoint(Offset(r.x, 0), radius: r, clockwise: false);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


// --- The NEW Aetherium Background ---
class AetheriumBackground extends StatefulWidget {
  final ScrollController scrollController;
  const AetheriumBackground({super.key, required this.scrollController});

  @override
  State<AetheriumBackground> createState() => _AetheriumBackgroundState();
}

class _AetheriumBackgroundState extends State<AetheriumBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    widget.scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = widget.scrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Color(0xff00001a), Color(0xff000000)],
            ),
          ),
        ),
        // Layer 2: Deep Parallax Starfield
        Transform.translate(
          offset: Offset(0, _scrollOffset * 0.1),
          child: const _Starfield(),
        ),
        // Layer 3: Drifting Aether Particles
        Transform.translate(
          offset: Offset(0, _scrollOffset * 0.4),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(sin(_animationController.value * 2 * pi) * 20, cos(_animationController.value * 2 * pi) * 20),
                child: child,
              );
            },
            child: const _AetherParticles(),
          ),
        ),
      ],
    );
  }
}

class _Starfield extends StatelessWidget {
  const _Starfield();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(),
      child: Container(),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final Paint starPaint = Paint();
  final int starCount = 500;
  late final List<Offset> stars;
  late final List<double> radii;

  _StarfieldPainter() {
    final random = Random(123); // Fixed seed for consistency
    stars = List.generate(starCount, (i) => Offset(random.nextDouble(), random.nextDouble()));
    radii = List.generate(starCount, (i) => random.nextDouble() * 0.8 + 0.2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < starCount; i++) {
      starPaint.color = Colors.white.withOpacity(radii[i] * 0.8);
      canvas.drawCircle(Offset(stars[i].dx * size.width, stars[i].dy * size.height), radii[i], starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AetherParticles extends StatelessWidget {
  const _AetherParticles();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 50,
          child: _AetherBlob(color: Colors.purple.withOpacity(0.2), size: 200),
        ),
        Positioned(
          bottom: 50,
          right: 20,
          child: _AetherBlob(color: Colors.blue.withOpacity(0.2), size: 300),
        ),
        Positioned(
          top: 300,
          right: 150,
          child: _AetherBlob(color: Colors.cyan.withOpacity(0.15), size: 150),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .move(duration: 20.seconds, begin: const Offset(-50, -50), end: const Offset(50, 50));
  }
}

class _AetherBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _AetherBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(decoration: const BoxDecoration(shape: BoxShape.circle)),
      ),
    );
  }
}


// --- HUD Frame Painter ---
class _HexagonFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(colors: [Colors.white, Colors.cyanAccent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path();
    path.moveTo(size.width * 0.25, 0); path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height * 0.5); path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height); path.lineTo(0, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Timeline Date Divider ---
class _TimelineDivider extends StatelessWidget {
  final Timestamp? timestamp;
  const _TimelineDivider({this.timestamp});
  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'TIMESTAMP UNKNOWN';
    final now = DateTime.now();
    final date = ts.toDate();
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = DateTime.utc(now.year, now.month, now.day - 1);
    final messageDate = DateTime.utc(date.year, date.month, date.day);
    if (messageDate == today) return 'TODAY';
    if (messageDate == yesterday) return 'YESTERDAY';
    return DateFormat('MMMM d, yyyy').format(date);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(_formatDate(timestamp), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// --- SELF-CONTAINED & ROBUST: Intelligent Avatar with Fallback ---
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
    final color1 = Color((hash & 0xFF0000) | 0xFF0055AA);
    final color2 = Color((hash & 0x00FF00) | 0xFFAA0055);
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color1.withOpacity(0.8), color2.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontSize: radius * 0.9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}