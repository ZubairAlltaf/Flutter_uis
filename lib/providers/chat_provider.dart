import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ChatUIStyle { minimalistic, cardBased, bubble }

class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _searchResults = [];
  ChatUIStyle _uiStyle = ChatUIStyle.minimalistic;

  // --- NEW: User profile cache ---
  final Map<String, Map<String, dynamic>> _userCache = {};

  User? get user => _user;
  List<Map<String, dynamic>> get chats => _chats;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  ChatUIStyle get uiStyle => _uiStyle;

  ChatProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _listenToChats();
      } else {
        // Clear data on logout
        _chats = [];
        _userCache.clear();
      }
      notifyListeners();
    });
  }

  void setUIStyle(ChatUIStyle style) {
    _uiStyle = style;
    notifyListeners();
  }

  // --- NEW: Efficiently gets user data, from cache if possible ---
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      _userCache[userId] = userData; // Save to cache
      return userData;
    }
    return {'name': 'Unknown', 'avatar': 'https://via.placeholder.com/50', 'email': ''};
  }

  void _listenToChats() {
    if (_user == null) return;
    _firestore
        .collection('chats')
        .where('participants', arrayContains: _user!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final chatFutures = snapshot.docs.map((doc) async {
        final data = doc.data();
        final otherUserId = (data['participants'] as List).firstWhere((id) => id != _user?.uid, orElse: () => null);
        if (otherUserId != null) {
          // --- UPDATED: Use the caching function ---
          final otherUserData = await _getUserData(otherUserId);
          return {
            'chatId': doc.id,
            'otherUser': otherUserData,
            'lastMessage': data['lastMessage'] ?? '',
            'timestamp': data['timestamp'],
            // --- NEW: Add typing status field ---
            'typing': data['typing'] ?? [],
          };
        }
        return null;
      }).toList();

      _chats = (await Future.wait(chatFutures)).whereType<Map<String, dynamic>>().toList();
      notifyListeners();
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    final snapshot = await _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    _searchResults = snapshot.docs
        .where((doc) => doc.id != _user?.uid)
        .map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'email': data['email'] ?? '',
        'avatar': data['avatar'] ?? 'https://via.placeholder.com/50',
      };
    })
        .toList();
    notifyListeners();
  }

  // --- NEW: Methods to handle typing status ---
  Future<void> updateUserTypingStatus(String chatId, bool isTyping) async {
    if (_user == null) return;
    final docRef = _firestore.collection('chats').doc(chatId);
    if (isTyping) {
      // Add user's UID to the typing array
      await docRef.update({
        'typing': FieldValue.arrayUnion([_user!.uid])
      });
    } else {
      // Remove user's UID from the typing array
      await docRef.update({
        'typing': FieldValue.arrayRemove([_user!.uid])
      });
    }
  }

// In chat_provider.dart

// In chat_provider.dart

  Future<String?> initiateChat(String otherUserId) async {
    try {
      if (_user == null) return null;
      // Generate a consistent, predictable chat ID
      final participants = [_user!.uid, otherUserId]..sort();
      final chatId = participants.join('_');

      final chatDocRef = _firestore.collection('chats').doc(chatId);

      await chatDocRef.set({
        'participants': participants,
        'typing': [], // Ensure base fields exist
        // --- ADD THIS LINE BACK ---
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return chatId;
    } catch (e) {
      print('Error initiating chat: $e');
      return null;
    }
  }

  void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    // ... (Your existing awesome SnackBar code remains unchanged)
    final colorScheme = isError
        ? (backgroundColor: Colors.red.withOpacity(0.2), borderColor: Colors.red.withOpacity(0.5), iconColor: Colors.redAccent)
        : (backgroundColor: Colors.cyan.withOpacity(0.2), borderColor: Colors.cyan.withOpacity(0.5), iconColor: Colors.cyanAccent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(width: 1.5, color: colorScheme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: colorScheme.iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, curve: Curves.easeOut),
      ),
    );
  }
}