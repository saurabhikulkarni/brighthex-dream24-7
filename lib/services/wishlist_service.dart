import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/product_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:convert';
import 'graphql_client.dart';
import 'graphql_queries.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  static const String _wishlistKey = 'wishlist_items';
  static const String _userIdKey = 'user_id';

  factory WishlistService() {
    return _instance;
  }

  WishlistService._internal();

  final GraphQLClient _graphQLClient = GraphQLService.getClient();

  // In-memory storage for wishlist items with their wishlist record IDs
  final List<Map<String, dynamic>> _wishlist = []; // {product, wishlistId}
  bool _isInitialized = false;

  // Initialize wishlist from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getStringList(_wishlistKey) ?? [];
      
      _wishlist.clear();
      for (String json in wishlistJson) {
        try {
          final wishlistMap = jsonDecode(json) as Map<String, dynamic>;
          _wishlist.add(wishlistMap);
        } catch (e) {
          print('Error parsing wishlist item: $e');
        }
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing wishlist: $e');
      _isInitialized = true;
    }
  }

  // Save wishlist to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = _wishlist
          .map((item) => jsonEncode(item))
          .toList();
      await prefs.setStringList(_wishlistKey, wishlistJson);
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  // Add product to wishlist (local cache)
  Future<void> addToWishlist(ProductModel product, {String? sizeId}) async {
    // Check if already exists
    if (!_wishlist.any((item) => item['product']?['id'] == product.id)) {
      _wishlist.insert(0, {
        'product': product.toJson(),
        'sizeId': sizeId,
        'wishlistId': null, // Will be set when synced with backend
      });
      await _saveToPreferences();
    }
  }

  // Remove product from wishlist (local cache)
  Future<void> removeFromWishlist(String productId) async {
    _wishlist.removeWhere((item) => item['product']?['id'] == productId);
    await _saveToPreferences();
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist.any((item) => item['product']?['id'] == productId);
  }

  // Get all wishlist items as ProductModel list
  List<ProductModel> getWishlist() {
    return _wishlist
        .map((item) {
          try {
            return ProductModel.fromJson(item['product'] as Map<String, dynamic>);
          } catch (e) {
            print('Error converting wishlist item: $e');
            return null;
          }
        })
        .whereType<ProductModel>()
        .toList();
  }

  // Get wishlist item count
  int getWishlistCount() {
    return _wishlist.length;
  }

  // Clear wishlist
  Future<void> clearWishlist() async {
    _wishlist.clear();
    await _saveToPreferences();
  }

  // Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist(ProductModel product, {String? sizeId}) async {
    if (isInWishlist(product.id!)) {
      // Remove from local and backend
      await removeFromWishlist(product.id!);
      await removeFromWishlistOnBackend(product.id!);
      return false; // Removed
    } else {
      // Add to local and backend
      await addToWishlist(product, sizeId: sizeId);
      await addToWishlistOnBackend(product.id!, sizeId: sizeId);
      // Sync to get the wishlist ID from backend
      await syncWithBackend();
      return true; // Added
    }
  }

  // Sync wishlist with backend via GraphQL
  Future<bool> syncWithBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        print('Error: User ID not found');
        return false;
      }

      // Fetch wishlist from GraphQL (from separate Wishlist collection)
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getUserWishlist),
        variables: {'userId': userId},
      );

      final QueryResult result = await _graphQLClient.query(options);

      if (result.hasException) {
        print('Error syncing wishlist with backend: ${result.exception}');
        return false;
      }

      final data = result.data;
      if (data != null && data['wishlists'] != null) {
        final wishlistData = data['wishlists'] as List?;
        if (wishlistData != null) {
          _wishlist.clear();
          for (var item in wishlistData) {
            try {
              final wishlistItem = item as Map<String, dynamic>;
              final productData = wishlistItem['product'] as Map<String, dynamic>?;
              if (productData != null) {
                _wishlist.add({
                  'product': productData,
                  'wishlistId': wishlistItem['id'],
                  'sizeId': wishlistItem['size']?['id'],
                });
              }
            } catch (e) {
              print('Error parsing wishlist item from backend: $e');
            }
          }
          await _saveToPreferences();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error syncing wishlist with backend: $e');
      return false;
    }
  }

  // Add to wishlist on backend via GraphQL (creates new Wishlist record)
  Future<bool> addToWishlistOnBackend(String productId, {String? sizeId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        print('Error: User ID not found');
        return false;
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.addToWishlist),
        variables: {
          'userId': userId,
          'productId': productId,
          'sizeId': sizeId,
        },
      );

      final QueryResult result = await _graphQLClient.mutate(options);

      if (result.hasException) {
        print('Error adding to wishlist on backend: ${result.exception}');
        return false;
      }

      return !result.hasException;
    } catch (e) {
      print('Error adding to wishlist on backend: $e');
      return false;
    }
  }

  // Remove from wishlist on backend via GraphQL (deletes Wishlist record by ID)
  Future<bool> removeFromWishlistOnBackend(String productId) async {
    try {
      // Find the wishlist record ID for this product
      final wishlistItem = _wishlist.firstWhere(
        (item) => item['product']?['id'] == productId,
        orElse: () => {},
      );

      final wishlistId = wishlistItem['wishlistId'];
      if (wishlistId == null) {
        print('Error: Wishlist ID not found for product $productId');
        return false;
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.removeFromWishlist),
        variables: {
          'wishlistId': wishlistId,
        },
      );

      final QueryResult result = await _graphQLClient.mutate(options);

      if (result.hasException) {
        print('Error removing from wishlist on backend: ${result.exception}');
        return false;
      }

      return !result.hasException;
    } catch (e) {
      print('Error removing from wishlist on backend: $e');
      return false;
    }
  }

  // Store user ID from login
  Future<void> setUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  // Clear wishlist (logout)
  Future<void> clear() async {
    try {
      _wishlist.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('Error clearing wishlist: $e');
    }
  }
}

// Global instance
final wishlistService = WishlistService();
