import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/product_model.dart';
import 'dart:convert';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  static const String _wishlistKey = 'wishlist_items';

  factory WishlistService() {
    return _instance;
  }

  WishlistService._internal();

  // In-memory storage for wishlist items
  final List<ProductModel> _wishlist = [];
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
          final productMap = jsonDecode(json) as Map<String, dynamic>;
          final product = ProductModel.fromJson(productMap);
          _wishlist.add(product);
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
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList(_wishlistKey, wishlistJson);
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(ProductModel product) async {
    // Check if already exists
    if (!_wishlist.any((item) => item.id == product.id)) {
      _wishlist.insert(0, product); // Add to beginning
      await _saveToPreferences();
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _wishlist.removeWhere((item) => item.id == productId);
    await _saveToPreferences();
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist.any((item) => item.id == productId);
  }

  // Get all wishlist items
  List<ProductModel> getWishlist() {
    return List.from(_wishlist);
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
  Future<bool> toggleWishlist(ProductModel product) async {
    if (isInWishlist(product.id!)) {
      await removeFromWishlist(product.id!);
      return false; // Removed
    } else {
      await addToWishlist(product);
      return true; // Added
    }
  }
}

final wishlistService = WishlistService();
