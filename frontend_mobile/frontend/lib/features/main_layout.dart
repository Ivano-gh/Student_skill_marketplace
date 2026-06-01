import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Import the stub screens that will be replaced later
import 'marketplace/screens/home_screen.dart';
import 'package:frontend/features/marketplace/screens/search_filter_screen.dart';
import 'selling/screens/create_listing_screen.dart';
import 'chat/screens/messages_inbox_screen.dart';
import 'profile/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchFilterScreen(),
    const CreateListingScreen(),
    const MessagesInboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            activeIcon: Icon(LucideIcons.home, fill: 1.0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.search),
            activeIcon: Icon(LucideIcons.search, fill: 1.0),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.plusSquare),
            activeIcon: Icon(LucideIcons.plusSquare, fill: 1.0),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageSquare),
            activeIcon: Icon(LucideIcons.messageSquare, fill: 1.0),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            activeIcon: Icon(LucideIcons.user, fill: 1.0),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
