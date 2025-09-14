import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutteruis/providers/chat_provider.dart';
import '../screens/homescreen/celestial_hub_screen3.dart';
import '../screens/homescreen/chronos_hub_screen4.dart';
import '../screens/homescreen/chronos_hub_screen5.dart';
import '../screens/homescreen/conversations_screen1.dart';
import '../screens/homescreen/nexus_hub_screen2.dart';


class CustomDrawer extends StatelessWidget {
  final ChatProvider chatProvider;

  const CustomDrawer({required this.chatProvider, super.key});

  @override
  Widget build(BuildContext context) {
    // Using a safe, dark theme for the drawer
    return Drawer(
      backgroundColor: const Color(0xff0a0a14), // A solid, dark, premium background
      child: SafeArea(
        // The main layout is a Column. This is key for layout control.
        child: Column(
          children: [
            // --- 1. A Clean Header for User Info ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.cyanAccent,
                    child: Text(
                      chatProvider.user?.email?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatProvider.user?.displayName ?? 'Guest User',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          chatProvider.user?.email ?? 'No email provided',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),

            // --- 2. THE OVERFLOW FIX ---
            // The Expanded widget forces the ListView to fill only the available
            // vertical space between the header and the logout button. This
            // is the definitive fix for the overflow error.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader('UI Styles'),
                  _buildStyleButton(context, ChatUIStyle.minimalistic, 'Minimalistic'),
                  _buildStyleButton(context, ChatUIStyle.cardBased, 'Card-Based'),
                  _buildStyleButton(context, ChatUIStyle.bubble, 'Bubble'),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Hub Screens'),
                  _buildNavButton(context, 'Conversations', () => const ConversationsScreen()),
                  _buildNavButton(context, 'Nexus Hub', () => const NexusHubScreen()),
                  _buildNavButton(context, 'Celestial Hub', () => const CelestialHubScreen()),
                  _buildNavButton(context, 'Chronos Hub', () => const ChronosHubScreen()),
                  _buildNavButton(context, 'Aetherium Hub', () => const AetheriumHubScreen()),
                ],
              ),
            ),

            // --- 3. A Persistent Footer for Logout ---
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close the drawer after signing out
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Helper for the UI style buttons
  Widget _buildStyleButton(BuildContext context, ChatUIStyle style, String title) {
    bool isSelected = chatProvider.uiStyle == style;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          chatProvider.setUIStyle(style);
          Navigator.pop(context);
        },
        tileColor: isSelected ? Colors.cyan.withOpacity(0.2) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.cyanAccent) : null,
      ),
    );
  }

  // Helper for the navigation buttons
  Widget _buildNavButton(BuildContext context, String title, Widget Function() screenBuilder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.dashboard_customize_outlined, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context); // Close drawer first
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screenBuilder()),
          );
        },
      ),
    );
  }
}
