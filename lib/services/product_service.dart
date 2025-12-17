import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';

class ProductService {
  final GraphQLClient _client = GraphQLService.getClient();

  // Fetch all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAllProducts),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getProductById),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['product'] == null) {
        return null;
      }

      return ProductModel.fromJson(
          result.data!['product'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getProductsByCategory),
          variables: {'category': category},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }

  // Fetch popular products
  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getPopularProducts),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching popular products: $e');
    }
  }

  // Fetch flash sale products
  Future<List<ProductModel>> getFlashSaleProducts() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getFlashSaleProducts),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching flash sale products: $e');
    }
  }

  // Fetch best sellers
  Future<List<ProductModel>> getBestSellers() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getBestSellers),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching best sellers: $e');
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String searchTerm) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.searchProducts),
          variables: {'searchTerm': searchTerm},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
