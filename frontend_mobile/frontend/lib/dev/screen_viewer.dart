import 'package:flutter/material.dart';

// AUTH
import 'package:frontend/features/auth/screens/splash_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/auth/screens/otp_verification_screen.dart';

// MAIN LAYOUT
import 'package:frontend/features/main_layout.dart';

// MARKETPLACE
import 'package:frontend/features/marketplace/screens/home_screen.dart';
import 'package:frontend/features/marketplace/screens/product_details_screen.dart';
import 'package:frontend/features/marketplace/screens/search_filter_screen.dart';
import 'package:frontend/core/marketplace/marketplace_provider.dart';

// CHAT
import 'package:frontend/features/chat/screens/messages_inbox_screen.dart';
import 'package:frontend/features/chat/screens/real_time_chat_screen.dart';

// PROFILE
import 'package:frontend/features/profile/screens/profile_screen.dart';

// SELLING
import 'package:frontend/features/selling/screens/create_listing_screen.dart';

// TRANSACTIONS
import 'package:frontend/features/transactions/screens/success_screen.dart';

// ADMIN
import 'package:frontend/features/admin/screens/admin_dashboard_screen.dart';

class ScreenViewer extends StatelessWidget {
  const ScreenViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      // AUTH
      {
        'name': 'Splash Screen',
        'screen': const SplashScreen(),
      },
      {
        'name': 'Login Screen',
        'screen': const LoginScreen(),
      },
      {
        'name': 'OTP Verification Screen',
        'screen': const OtpVerificationScreen(email: 'test@st.rmu.edu.gh'),
      },

      // MAIN
      {
        'name': 'Main Layout',
        'screen': const MainLayout(),
      },

      // MARKETPLACE
      {
        'name': 'Home Screen',
        'screen': const HomeScreen(),
      },
      {
        'name': 'Product Details',
        'screen': ProductDetailsScreen(
          listing: ListingItem(
            id: 1,
            title: 'Test Product',
            price: 'GH₵ 100',
            condition: 'New',
            description:
                'This is a demo listing used only for the dev screen viewer.',
            category: 'Electronics',
            sellerName: 'Demo Seller',
            sellerEmail: 'demo@st.rmu.edu.gh',
            sellerLevel: 'Verified Seller',
            sellerId: 42,
          ),
        ),
      },
      {
        'name': 'Search & Filter',
        'screen': const SearchFilterScreen(),
      },

      // CHAT
      {
        'name': 'Messages Inbox',
        'screen': const MessagesInboxScreen(),
      },
      {
        'name': 'Real-Time Chat',
        'screen': const RealTimeChatScreen(
          contactName: 'John Doe',
          itemTitle: 'Laptop',
        ),
      },

      // PROFILE
      {
        'name': 'Profile Screen',
        'screen': const ProfileScreen(),
      },

      // SELLING
      {
        'name': 'Create Listing',
        'screen': const CreateListingScreen(),
      },

      // TRANSACTIONS
      {
        'name': 'Success Screen',
        'screen': SuccessScreen(
          title: 'Success',
          message: 'Your transaction was successful.',
          onContinue: () {
            // Handle continue action, e.g., navigate back
          },
        ),
      },

      // ADMIN
      {
        'name': 'Admin Dashboard',
        'screen': const AdminDashboardScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Screens (Dev Mode)'),
      ),
      body: ListView.builder(
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final item = screens[index];

          return ListTile(
            title: Text(item['name'] as String),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => item['screen'] as Widget,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
