import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(context, '1,240', 'Total Users', LucideIcons.users),
                const SizedBox(width: 16),
                _buildStatCard(context, '458', 'Active Listings', LucideIcons.package),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(context, '12', 'Reports', LucideIcons.alertTriangle, isWarning: true),
                const SizedBox(width: 16),
                _buildStatCard(context, 'GH₵ 42k', 'Total Vol.', LucideIcons.trendingUp),
              ],
            ),
            const SizedBox(height: 32),
            
            Text('Recent Reports', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.alertCircle, color: Colors.red),
                    ),
                    title: const Text('Inappropriate Content'),
                    subtitle: const Text('Reported on: "Iphone 12 Pro Max"'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Review'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, {bool isWarning = false}) {
    final theme = Theme.of(context);
    final color = isWarning ? Colors.red : theme.primaryColor;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 28,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
