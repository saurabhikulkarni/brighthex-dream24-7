import 'package:shop/models/product_model.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();

  factory WishlistService() {
    return _instance;
  }

  WishlistService._internal();

  // In-memory storage for wishlist items
  final List<ProductModel> _wishlist = [];

  // Add product to wishlist
  void addToWishlist(ProductModel product) {
    // Check if already exists
    if (!_wishlist.any((item) => item.id == product.id)) {
      _wishlist.insert(0, product); // Add to beginning
    }
  }

  // Remove product from wishlist
  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((item) => item.id == productId);
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
  void clearWishlist() {
    _wishlist.clear();
  }

  // Toggle wishlist (add if not exists, remove if exists)
  bool toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id!)) {
      removeFromWishlist(product.id!);
      return false; // Removed
    } else {
      addToWishlist(product);
      return true; // Added
    }
  }
}

final wishlistService = WishlistService();
