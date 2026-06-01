import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/auth/auth_provider.dart';
import 'real_time_chat_screen.dart';

class MessagesInboxScreen extends StatelessWidget {
  const MessagesInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuest = !authProvider.isLoggedIn;

    // Mock data
    final messages = [
      {'name': 'Sarah Jenkins', 'item': 'HP Laptop i5', 'msg': 'Is this still available?', 'time': '2m ago', 'unread': true},
      {'name': 'Michael Owusu', 'item': 'Engineering Math Vol 2', 'msg': 'I can do GH₵ 100 if we meet today.', 'time': '1h ago', 'unread': false},
      {'name': 'Abena Mensah', 'item': 'Dorm Fridge', 'msg': 'Thanks for the sale!', 'time': 'Yesterday', 'unread': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: isGuest
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your inbox is ready.',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login or register to access chats with sellers and buyers.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text('Login to Continue'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
        itemCount: messages.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.dividerColor.withValues(alpha: 0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final chat = messages[index];
          final unread = chat['unread'] as bool;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    (chat['name'] as String).substring(0, 1),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chat['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                Text(
                  chat['time'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: unread ? theme.colorScheme.secondary : theme.textTheme.bodyMedium?.color,
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Re: ${chat['item']}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chat['msg'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unread ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodyMedium?.color,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RealTimeChatScreen(
                    contactName: chat['name'] as String,
                    itemTitle: chat['item'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
