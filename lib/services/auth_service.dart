import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/wallet_service.dart';
import 'package:shop/services/wishlist_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final GraphQLClient _graphQLClient = GraphQLService.getClient();

  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userPhoneKey = 'user_phone';
  static const String _userNameKey = 'user_name';
  static const String _phoneVerifiedKey = 'phone_verified';
  static const String _walletBalanceKey = 'wallet_balance';
  static const String _authTokenKey = 'auth_token';
  static const String _lastLoginKey = 'last_login';
  static const String _userIdKey = 'user_id';

  bool _isInitialized = false;

  // Initialize auth service from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Check if phone is verified
  Future<bool> isPhoneVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_phoneVerifiedKey) ?? false;
    } catch (e) {
      print('Error checking phone verification: $e');
      return false;
    }
  }

  // Get user phone
  Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userPhoneKey);
    } catch (e) {
      print('Error getting user phone: $e');
      return null;
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Save login session
  Future<void> saveLoginSession({
    required String phone,
    required String name,
    required bool phoneVerified,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      await prefs.setBool(_phoneVerifiedKey, phoneVerified);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      
      // Store userId and set it in wallet/wishlist services
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(_userIdKey, userId);
        // Set userId in wallet and wishlist services for GraphQL backend sync
        await walletService.setUserId(userId);
        await wishlistService.setUserId(userId);
      }
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  // Mark phone as verified
  Future<void> markPhoneVerified(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setBool(_phoneVerifiedKey, true);
    } catch (e) {
      print('Error marking phone as verified: $e');
    }
  }

  // Clear login session (logout)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_phoneVerifiedKey);
      await prefs.remove(_walletBalanceKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_userIdKey);
      
      // Clear wallet and wishlist services on logout
      await walletService.clear();
      await wishlistService.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(_lastLoginKey);
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      return null;
    } catch (e) {
      print('Error getting last login time: $e');
      return null;
    }
  }

  // Get wallet balance
  Future<double> getWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_walletBalanceKey) ?? 0.0;
    } catch (e) {
      print('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Update wallet balance
  Future<void> updateWalletBalance(double newBalance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_walletBalanceKey, newBalance);
    } catch (e) {
      print('Error updating wallet balance: $e');
    }
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Save login session with wallet balance
  Future<void> saveLoginSessionWithToken({
    required String phone,
    required String name,
    required bool phoneVerified,
    required double walletBalance,
    required String authToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      await prefs.setBool(_phoneVerifiedKey, phoneVerified);
      await prefs.setDouble(_walletBalanceKey, walletBalance);
      await prefs.setString(_authTokenKey, authToken);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  // Fetch user profile from GraphQL backend
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getUserProfile),
        variables: {'userId': userId},
      );

      final QueryResult result = await _graphQLClient.query(options);

      if (result.hasException) {
        print('Error fetching user profile: ${result.exception}');
        return null;
      }

      final data = result.data?['userDetail'];
      if (data != null) {
        // Update local wallet balance from backend
        if (data['walletBalance'] != null) {
          await updateWalletBalance(data['walletBalance'].toDouble());
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Exception in fetchUserProfile: $e');
      return null;
    }
  }
}

// Global instance
final authService = AuthService();
