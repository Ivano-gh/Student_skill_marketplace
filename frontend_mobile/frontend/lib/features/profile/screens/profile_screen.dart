import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/auth/auth_provider.dart';
import 'package:frontend/core/theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuest = !authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      'JD',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                      child: const Icon(LucideIcons.edit2, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isGuest ? 'Guest Shopper' : authProvider.username.isNotEmpty ? authProvider.username : 'RMU Student',
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              isGuest ? 'Browse listings or login to transact' : authProvider.email,
              style: theme.textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 32),
            
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildStatCard(context, '12', 'Active\nListings'),
                  const SizedBox(width: 16),
                  _buildStatCard(context, '45', 'Items\nSold'),
                  const SizedBox(width: 16),
                  _buildStatCard(context, 'GH₵ 850', 'Total\nEarned'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings List
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(LucideIcons.package, color: theme.primaryColor),
                    title: const Text('My Listings'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(LucideIcons.heart, color: theme.primaryColor),
                    title: const Text('Saved Items'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                      color: theme.primaryColor,
                    ),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeThumbColor: theme.primaryColor,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(LucideIcons.bell, color: theme.primaryColor),
                    title: const Text('Notifications'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(LucideIcons.shield, color: theme.primaryColor),
                    title: const Text('Account Security'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      isGuest ? LucideIcons.logIn : LucideIcons.logOut,
                      color: isGuest ? theme.primaryColor : Colors.red,
                    ),
                    title: Text(
                      isGuest ? 'Login / Register' : 'Log Out',
                      style: TextStyle(
                        color: isGuest ? theme.primaryColor : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      if (isGuest) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        authProvider.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
