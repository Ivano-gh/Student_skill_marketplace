import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListingItem {
  final int id;
  final String title;
  final String price;
  final String condition;
  final String description;
  final String category;
  final String sellerName;
  final String sellerEmail;
  final String sellerLevel;
  final int sellerId;

  ListingItem({
    required this.id,
    required this.title,
    required this.price,
    required this.condition,
    required this.description,
    required this.category,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerLevel,
    required this.sellerId,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'];
    final formattedPrice = priceValue != null ? 'GH₵ ${priceValue.toString()}' : 'GH₵ 0.00';
    return ListingItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: formattedPrice,
      condition: json['condition'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      sellerName: json['seller_name'] as String? ?? 'Unknown Seller',
      sellerEmail: json['seller_email'] as String? ?? '',
      sellerLevel: json['seller_level'] as String? ?? 'Verified Seller',
      sellerId: json['seller_id'] as int? ?? 0,
    );
  }
}

class MarketplaceProvider extends ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/auth';

  final List<ListingItem> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ListingItem> get listings => List.unmodifiable(_listings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        _listings
          ..clear()
          ..addAll(data.map((item) => ListingItem.fromJson(item as Map<String, dynamic>)));
      } else {
        _errorMessage = 'Unable to load listings. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Cannot connect to backend: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createListing({
    required String title,
    required String category,
    required String condition,
    required String description,
    required double price,
    required String token,
  }) async {
    final categoryMapping = {
      'Textbooks': 'textbook',
      'Electronics': 'electronics',
      'Dorm Essentials': 'other',
      'Services': 'service',
      'Tutoring': 'tutoring',
      'Design': 'design',
      'Other': 'other',
    };

    final conditionMapping = {
      'New': 'new',
      'Like New': 'like-new',
      'Used - Good': 'good',
      'Used - Fair': 'fair',
      'Poor': 'poor',
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'category': categoryMapping[category] ?? 'other',
          'condition': conditionMapping[condition] ?? 'good',
          'price': price,
          'delivery_method': 'pickup',
          'image_urls': ['https://via.placeholder.com/300'],
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _listings.insert(0, ListingItem.fromJson(data));
        notifyListeners();
        return true;
      }

      final responseData = json.decode(response.body);
      debugPrint('Create listing failed (${response.statusCode}): $responseData');
    } catch (error) {
      debugPrint('Create listing exception: $error');
    }

    return false;
  }

  Future<bool> purchaseProduct({
    required int productId,
    required double amount,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'product': productId,
          'agreed_price': amount,
        }),
      );

      if (response.statusCode == 201) {
        _listings.removeWhere((item) => item.id == productId);
        notifyListeners();
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<bool> sendMessage({
    required int productId,
    required int receiverId,
    required String message,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiver_id': receiverId,
          'product_id': productId,
          'message_text': message,
        }),
      );

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
