import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../screens/chat_screens/messaging_screen1.dart';

class UserSearchDelegate extends SearchDelegate {
  final ChatProvider chatProvider;
  Timer? _debounce;

  UserSearchDelegate(this.chatProvider) {
    // Clear previous search results when opening
    chatProvider.searchUsers('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: const Color(0xff1a1a2e),
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff16213e),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, decoration: TextDecoration.none),
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
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<ChatProvider>(
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
                backgroundImage: NetworkImage(user['avatar'] ?? 'https://i.pravatar.cc/150?u=${user['id']}'),
              ),
              title: Text(user['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
              subtitle: Text(user['email'] ?? '', style: const TextStyle(color: Colors.white70)),
              onTap: () async {
                final chatId = await chatProvider.initiateChat(user['id']);
                if (chatId != null && context.mounted) {
                  close(context, null); // Close search screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingScreen(chatId: chatId, otherUser: user),
                    ),
                  );
                }
              },
            ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      chatProvider.searchUsers(query);
    });
    return buildResults(context);
  }
}