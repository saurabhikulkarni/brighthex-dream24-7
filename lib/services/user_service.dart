import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';

class UserService {
  final GraphQLClient _client = GraphQLService.getClient();

  // For now, using a local user ID - in production, get from auth state
  static String? _currentUserId;

  // Set current user ID (call this after login)
  static void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return _currentUserId;
  }

  // Fetch user by ID
  Future<UserDetailModel?> getUserById(String userId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserById),
          variables: {'id': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['userDetail'] == null) {
        return null;
      }

      return UserDetailModel.fromJson(
          result.data!['userDetail'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Fetch user by mobile number (for login with OTP)
  Future<UserDetailModel?> getUserByMobileNumber(String mobileNumber) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserByMobileNumber),
          variables: {'mobileNumber': mobileNumber},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || 
          result.data!['userDetails'] == null || 
          (result.data!['userDetails'] as List).isEmpty) {
        return null;
      }

      final users = result.data!['userDetails'] as List;
      if (users.isEmpty) return null;

      return UserDetailModel.fromJson(users[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Fetch user by username (for backward compatibility)
  Future<UserDetailModel?> getUserByUsername(String username) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserByUsername),
          variables: {'username': username},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || 
          result.data!['userDetails'] == null || 
          (result.data!['userDetails'] as List).isEmpty) {
        return null;
      }

      final users = result.data!['userDetails'] as List;
      if (users.isEmpty) return null;

      return UserDetailModel.fromJson(users[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Get current user's wallet balance
  Future<double> getWalletBalance() async {
    if (_currentUserId == null) return 0.0;

    try {
      final user = await getUserById(_currentUserId!);
      return user?.walletBalance ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Update wallet balance
  Future<bool> updateWalletBalance(String userId, double newBalance) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateWalletBalance),
          variables: {
            'userId': userId,
            'walletBalance': newBalance,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Publish the update
      if (result.data != null && result.data!['updateUserDetail'] != null) {
        final updatedUserId = result.data!['updateUserDetail']['id'];
        await _publishUser(updatedUserId);
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Error updating wallet balance: $e');
    }
  }

  // Add money to wallet (increment)
  Future<double?> addWalletBalance(String userId, double amount) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.addWalletBalance),
          variables: {
            'userId': userId,
            'amount': amount,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Publish the update
      if (result.data != null && result.data!['updateUserDetail'] != null) {
        final updatedUser = result.data!['updateUserDetail'];
        final updatedUserId = updatedUser['id'];
        await _publishUser(updatedUserId);
        return (updatedUser['walletBalance'] ?? 0).toDouble();
      }

      return null;
    } catch (e) {
      throw Exception('Error adding wallet balance: $e');
    }
  }

  // Deduct money from wallet (decrement)
  Future<double?> deductWalletBalance(String userId, double amount) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deductWalletBalance),
          variables: {
            'userId': userId,
            'amount': amount,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Publish the update
      if (result.data != null && result.data!['updateUserDetail'] != null) {
        final updatedUser = result.data!['updateUserDetail'];
        final updatedUserId = updatedUser['id'];
        await _publishUser(updatedUserId);
        return (updatedUser['walletBalance'] ?? 0).toDouble();
      }

      return null;
    } catch (e) {
      throw Exception('Error deducting wallet balance: $e');
    }
  }

  // Publish user (required for Hygraph)
  Future<void> _publishUser(String userId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishUser),
          variables: {'id': userId},
        ),
      );
    } catch (e) {
      // Silently fail publish - balance is still updated
    }
  }
}

// Singleton instance
final userService = UserService();
