import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/auth/auth_provider.dart';
import 'package:frontend/core/marketplace/marketplace_provider.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Textbooks';
  String _selectedCondition = 'New';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'Please log in or register before you add a new listing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/signup');
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitListing(
    BuildContext context,
    MarketplaceProvider marketplaceProvider,
    bool isGuest,
  ) async {
    if (isGuest) {
      _showAuthDialog(context);
      return;
    }

    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all listing fields.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    if (token == null || token.isEmpty) {
      _showAuthDialog(context);
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price value.')),
      );
      return;
    }

    final success = await marketplaceProvider.createListing(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      condition: _selectedCondition,
      description: _descriptionController.text.trim(),
      price: price,
      token: token,
    );

    if (success) {
      // Refresh listings to show the new item immediately
      await marketplaceProvider.fetchListings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // ignore: use_build_context_synchronously
        const SnackBar(content: Text('Listing created successfully!')),
      );
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = 'Textbooks';
        _selectedCondition = 'New';
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( // ignore: use_build_context_synchronously
        const SnackBar(content: Text('Unable to create listing. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final marketplaceProvider = Provider.of<MarketplaceProvider>(
      context,
      listen: false,
    );
    final isGuest = !authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell an Item'),
        actions: [
          TextButton(
            onPressed: () {
              // Save Draft or Clear
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            Text('Photos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add up to 5 photos of what you are selling.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.05),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.camera, color: theme.primaryColor),
                        const SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mock Added Photo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details
            Text('Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Engineering Math Vol 2',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (GH₵)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                'Textbooks',
                'Electronics',
                'Dorm Essentials',
                'Services',
                'Tutoring',
                'Design',
                'Other',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // Condition Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: [
                'New',
                'Like New',
                'Used - Good',
                'Used - Fair',
                'Poor',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCondition = val);
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Describe what you are selling and any details buyers should know...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            if (isGuest) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'You must log in to publish a listing. Please sign in or create an account.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isGuest
                    ? () => _showAuthDialog(context)
                    : () => _submitListing(context, marketplaceProvider, isGuest),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGuest
                      ? theme.primaryColor.withOpacity(0.65)
                      : theme.primaryColor,
                ),
                child: Text(isGuest ? 'Login to Publish' : 'Publish Listing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
