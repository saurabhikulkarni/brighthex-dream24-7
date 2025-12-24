import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';

class UserService {
  final GraphQLClient _client = GraphQLService.getClient();

  // For now, using a local user ID - in production, get from auth state
  static String? _currentUserId;
  static SharedPreferences? _prefs;

  // Initialize UserService (call on app startup)
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentUserId = _prefs?.getString('user_id');
    print('[USER_SERVICE] Initialized - userId from prefs: $_currentUserId');
  }

  // Set current user ID (call this after login)
  static Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId.isEmpty ? null : userId;
    // Also persist to SharedPreferences
    if (_prefs != null) {
      if (userId.isNotEmpty) {
        await _prefs!.setString('user_id', userId);
      } else {
        await _prefs!.remove('user_id');
      }
    }
  }

  // Get current user ID - checks SharedPreferences if static var is null (e.g., after hot reload)
  static String? getCurrentUserId() {
    // Return static variable if set
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId;
    }
    
    // Fall back to SharedPreferences if available
    if (_prefs != null) {
      _currentUserId = _prefs!.getString('user_id');
    }
    
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
      // Clean phone number (remove non-digit characters)
      final cleanPhone = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserByMobileNumber),
          variables: {'mobileNumber': cleanPhone},
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
      // First check if we have a cached balance in SharedPreferences
      // This is important for test users and offline mode
      final prefs = await SharedPreferences.getInstance();
      final cachedBalance = prefs.getDouble('wallet_balance');
      
      print('[USER_SERVICE] Getting wallet balance for userId: $_currentUserId');
      print('[USER_SERVICE] Cached balance from SharedPreferences: $cachedBalance');
      
      // Try to get from backend
      try {
        final user = await getUserById(_currentUserId!);
        final backendBalance = user?.walletBalance ?? 0.0;
        print('[USER_SERVICE] Backend balance: $backendBalance');
        
        // Update cache with backend value if it's valid
        if (backendBalance > 0) {
          await prefs.setDouble('wallet_balance', backendBalance);
          print('[USER_SERVICE] Updated cache with backend balance: $backendBalance');
          return backendBalance;
        }
      } catch (e) {
        print('[USER_SERVICE] Error fetching from backend, using cached: $e');
      }
      
      // Return cached balance if backend fails or returns 0
      final finalBalance = cachedBalance ?? 0.0;
      print('[USER_SERVICE] Returning final balance: $finalBalance');
      return finalBalance;
    } catch (e) {
      print('[USER_SERVICE] Error in getWalletBalance: $e');
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
            'walletBalance': newBalance.toInt(),
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
      print('[USER_SERVICE] Adding wallet balance: userId=$userId, amount=$amount');
      
      // Get current balance from cache first
      final prefs = await SharedPreferences.getInstance();
      final currentBalance = await getWalletBalance();
      final newBalance = currentBalance + amount;
      
      print('[USER_SERVICE] Current balance: $currentBalance, New balance: $newBalance');
      
      // Update cache immediately
      await prefs.setDouble('wallet_balance', newBalance);
      print('[USER_SERVICE] Updated SharedPreferences wallet_balance to: $newBalance');
      
      // Verify it was saved
      final verifyBalance = prefs.getDouble('wallet_balance');
      print('[USER_SERVICE] Verified SharedPreferences wallet_balance: $verifyBalance');
      
      // Try to update backend (will fail for test users, but that's OK)
      try {
        final user = await getUserById(userId);
        if (user != null) {
          // Update with new calculated balance
          final QueryResult result = await _client.mutate(
            MutationOptions(
              document: gql(GraphQLQueries.updateWalletBalance),
              variables: {
                'userId': userId,
                'walletBalance': newBalance.toInt(),
              },
            ),
          );

          if (!result.hasException && result.data != null && result.data!['updateUserDetail'] != null) {
            final updatedUser = result.data!['updateUserDetail'];
            final updatedUserId = updatedUser['id'];
            final returnedBalance = (updatedUser['walletBalance'] ?? 0).toDouble();
            print('[USER_SERVICE] New wallet balance from backend: $returnedBalance');
            
            await _publishUser(updatedUserId);
            await prefs.setDouble('wallet_balance', returnedBalance);
            return returnedBalance;
          }
        }
      } catch (e) {
        print('[USER_SERVICE] Backend update failed (expected for test user): $e');
      }

      // Return the new balance from cache
      print('[USER_SERVICE] Returning cached balance: $newBalance');
      return newBalance;
    } catch (e) {
      print('Exception in addWalletBalance: $e'); // Debug
      throw Exception('Error adding wallet balance: $e');
    }
  }

  // Deduct money from wallet (decrement)
  Future<double?> deductWalletBalance(String userId, double amount) async {
    try {
      // First, get current balance
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final currentBalance = user.walletBalance;
      final newBalance = (currentBalance - amount).toInt();
      
      // Don't allow negative balance
      if (newBalance < 0) {
        throw Exception('Insufficient wallet balance');
      }
      
      // Update with new calculated balance
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
