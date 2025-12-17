import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';

class CartService {
  final GraphQLClient _client = GraphQLService.getClient();

  // Local cart storage (for now, until user auth is implemented)
  static final List<CartModel> _localCart = [];

  // Get local cart items
  List<CartModel> getLocalCart() {
    return _localCart;
  }

  // Add item to local cart
  void addToLocalCart(ProductModel product, SizeModel? size, int quantity) {
    // Check if product already exists in cart
    final existingIndex = _localCart.indexWhere(
      (item) => item.product?.id == product.id && item.size?.id == size?.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      final existingItem = _localCart[existingIndex];
      _localCart[existingIndex] = CartModel(
        id: existingItem.id,
        quantity: existingItem.quantity + quantity,
        product: existingItem.product,
        size: existingItem.size,
      );
    } else {
      // Add new item
      _localCart.add(CartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        quantity: quantity,
        product: product,
        size: size,
      ));
    }
  }

  // Update cart item quantity
  void updateLocalCartQuantity(String cartItemId, int quantity) {
    final index = _localCart.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _localCart[index];
      _localCart[index] = CartModel(
        id: item.id,
        quantity: quantity,
        product: item.product,
        size: item.size,
      );
    }
  }

  // Remove item from local cart
  void removeFromLocalCart(String cartItemId) {
    _localCart.removeWhere((item) => item.id == cartItemId);
  }

  // Clear local cart
  void clearLocalCart() {
    _localCart.clear();
  }

  // Calculate total
  double getCartTotal() {
    return _localCart.fold(0, (sum, item) {
      final price = item.product?.price ?? 0;
      return sum + (price * item.quantity);
    });
  }

  // Get cart item count
  int getCartItemCount() {
    return _localCart.fold(0, (sum, item) => sum + item.quantity);
  }

  // ============ GraphQL Methods (for when user auth is implemented) ============

  // Fetch cart items for a user from GraphQL
  Future<List<CartModel>> getCartByUser(String userId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getCartByUser),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['carts'] == null) {
        return [];
      }

      final List<dynamic> cartsJson = result.data!['carts'] as List<dynamic>;
      return cartsJson
          .map((json) => CartModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  // Add item to cart via GraphQL
  Future<CartModel?> addToCart({
    required String userId,
    required String productId,
    String? sizeId,
    int quantity = 1,
  }) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createCartItem),
          variables: {
            'userId': userId,
            'productId': productId,
            'sizeId': sizeId,
            'quantity': quantity,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['createCart'] == null) {
        return null;
      }

      // Publish the cart item
      final cartId = result.data!['createCart']['id'];
      await _publishCart(cartId);

      return CartModel.fromJson(
          result.data!['createCart'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Update cart item quantity
  Future<bool> updateCartQuantity(String cartId, int quantity) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateCartItem),
          variables: {
            'cartId': cartId,
            'quantity': quantity,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return true;
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  // Delete cart item
  Future<bool> deleteCartItem(String cartId) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteCartItem),
          variables: {'cartId': cartId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return true;
    } catch (e) {
      throw Exception('Error deleting cart item: $e');
    }
  }

  // Publish cart (required for Hygraph)
  Future<void> _publishCart(String cartId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishCart),
          variables: {'id': cartId},
        ),
      );
    } catch (e) {
      // Silently fail publish - item is still created
    }
  }
}

// Singleton instance for easy access
final cartService = CartService();
