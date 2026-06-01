import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/auth/auth_provider.dart';
import 'package:frontend/core/marketplace/marketplace_provider.dart';
import '../../transactions/screens/success_screen.dart';
import '../../chat/screens/real_time_chat_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ListingItem? listing;

  const ProductDetailsScreen({super.key, this.listing});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'Please sign in or register to message the seller, view full details, or complete a purchase.',
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

  Future<void> _placeOrder(
    ListingItem listing,
    String token,
    MarketplaceProvider marketplaceProvider,
  ) async {
    final success = await marketplaceProvider.purchaseProduct(
      productId: listing.id,
      amount: double.tryParse(listing.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      token: token,
    );

    if (!mounted) return;

    final scaffold = ScaffoldMessenger.of(context);

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: 'Purchase Confirmed',
            message:
                'Your order has been placed successfully. The seller will contact you soon to arrange pickup or delivery.',
            onContinue: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    } else {
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Unable to place order. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _messageSeller(
    ListingItem listing,
    String token,
    MarketplaceProvider marketplaceProvider,
  ) async {
    final success = await marketplaceProvider.sendMessage(
      productId: listing.id,
      receiverId: listing.sellerId,
      message: 'Hi, I am interested in your listing: ${listing.title}. Please contact me.',
      token: token,
    );

    if (!mounted) return;

    final scaffold = ScaffoldMessenger.of(context);

    if (success) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Message sent to seller.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RealTimeChatScreen(
            contactName: listing.sellerName,
            itemTitle: listing.title,
          ),
        ),
      );
    } else {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    final isGuest = !authProvider.isLoggedIn;
    
    // Dummy listing data if none provided
    final dummyListing = ListingItem(
      id: 1,
      title: 'HP Pavilion 15 Laptop - Intel i5',
      price: 'GH₵ 2500',
      condition: 'Like New',
      description: 'Excellent condition HP laptop with Intel i5 processor, 8GB RAM, 256GB SSD. Perfect for students and professionals. Only 3 months old, barely used. Original box and charger included. Willing to negotiate for serious buyers.',
      category: 'electronics',
      sellerName: 'David Asante',
      sellerEmail: 'david@st.rmu.edu.gh',
      sellerLevel: 'Verified Seller',
      sellerId: 5,
    );
    
    final listing = widget.listing ?? dummyListing;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: theme.iconTheme.color),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                LucideIcons.heart,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                if (isGuest) {
                  _showAuthDialog(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                }
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Hero
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.image,
                  size: 100,
                  color: theme.primaryColor.withValues(alpha: 0.4),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.condition,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text('Posted 2h ago', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    listing.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    listing.price,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Seller Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                          child: Text(
                            listing.sellerName
                                .split(' ')
                                .map((word) => word.isEmpty ? '' : word[0])
                                .join(),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.sellerName,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                listing.sellerLevel,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isGuest) ...[
                    const SizedBox(height: 24),
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
                        'Sign in to view seller contact details, message the seller, and complete the purchase.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Text('Description', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),

                  Text(
                    listing.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  if (!isGuest) ...[
                    const SizedBox(height: 24),
                    Text('Contact', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(
                      'Email: ${listing.sellerEmail}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${listing.category}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isGuest || authProvider.accessToken == null) {
                    _showAuthDialog(context);
                  } else {
                    _messageSeller(
                      listing,
                      authProvider.accessToken!,
                      marketplaceProvider,
                    );
                  }
                },
                icon: const Icon(LucideIcons.messageCircle),
                label: const Text('Message Seller'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isGuest || authProvider.accessToken == null) {
                    _showAuthDialog(context);
                  } else {
                    _placeOrder(
                      listing,
                      authProvider.accessToken!,
                      marketplaceProvider,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
