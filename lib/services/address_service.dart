import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/user_service.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  
  factory AddressService() {
    return _instance;
  }
  
  AddressService._internal();

  final GraphQLClient _client = GraphQLService.getClient();

  // Get all addresses for current user
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserAddresses),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['addresses'] == null) {
        return [];
      }

      final List<dynamic> addressesJson = result.data!['addresses'] as List<dynamic>;
      return addressesJson
          .map((json) => AddressModel.fromJson({
                ...json as Map<String, dynamic>,
                'userId': userId, // Add userId from context
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }

  // Get address by ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAddressById),
          variables: {'id': addressId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['address'] == null) {
        return null;
      }

      final userId = UserService.getCurrentUserId();
      return AddressModel.fromJson({
        ...result.data!['address'] as Map<String, dynamic>,
        'userId': userId ?? '',
      });
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
  }

  // Create new address
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // If setting as default, first unset other default addresses
      if (address.isDefault) {
        await _unsetDefaultAddresses(userId);
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.createAddress),
        variables: {
          'userId': userId,
          'fullName': address.fullName,
          'phoneNumber': address.phoneNumber,
          'pincode': address.pincode,
          'addressLine1': address.addressLine1,
          'addressLine2': address.addressLine2,
          'city': address.city,
          'state': address.state,
          'country': address.country,
          'isDefault': address.isDefault,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final createdAddress = result.data?['createAddress'];
      if (createdAddress == null) {
        throw Exception('Failed to create address');
      }

      // Publish address
      final addressId = createdAddress['id']?.toString();
      if (addressId != null) {
        await _publishAddress(addressId);
      }

      return AddressModel.fromJson({
        ...createdAddress as Map<String, dynamic>,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Error creating address: $e');
    }
  }

  // Update address
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      if (address.id == null) {
        throw Exception('Address ID is required for update');
      }

      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // If setting as default, first unset other default addresses
      if (address.isDefault) {
        await _unsetDefaultAddresses(userId, excludeId: address.id);
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateAddress),
        variables: {
          'id': address.id,
          'fullName': address.fullName,
          'phoneNumber': address.phoneNumber,
          'pincode': address.pincode,
          'addressLine1': address.addressLine1,
          'addressLine2': address.addressLine2,
          'city': address.city,
          'state': address.state,
          'country': address.country,
          'isDefault': address.isDefault,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final updatedAddress = result.data?['updateAddress'];
      if (updatedAddress == null) {
        throw Exception('Failed to update address');
      }

      // Publish address
      await _publishAddress(address.id!);

      return AddressModel.fromJson({
        ...updatedAddress as Map<String, dynamic>,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.deleteAddress),
        variables: {'id': addressId},
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['deleteAddress'] != null;
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }

  // Set address as default
  Future<AddressModel> setDefaultAddress(String addressId) async {
    try {
      final address = await getAddressById(addressId);
      if (address == null) {
        throw Exception('Address not found');
      }

      final updatedAddress = address.copyWith(isDefault: true);
      return await updateAddress(updatedAddress);
    } catch (e) {
      throw Exception('Error setting default address: $e');
    }
  }

  // Get default address
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final addresses = await getUserAddresses();
      try {
        return addresses.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        return addresses.isNotEmpty ? addresses.first : null;
      }
    } catch (e) {
      throw Exception('Error getting default address: $e');
    }
  }

  // Helper: Unset default addresses (except excluded ID)
  Future<void> _unsetDefaultAddresses(String userId, {String? excludeId}) async {
    try {
      final addresses = await getUserAddresses();
      for (final address in addresses) {
        if (address.isDefault && address.id != excludeId) {
          // Update without republishing immediately
          await _client.mutate(
            MutationOptions(
              document: gql(GraphQLQueries.updateAddress),
              variables: {
                'id': address.id,
                'fullName': address.fullName,
                'phoneNumber': address.phoneNumber,
                'pincode': address.pincode,
                'addressLine1': address.addressLine1,
                'addressLine2': address.addressLine2,
                'city': address.city,
                'state': address.state,
                'country': address.country,
                'isDefault': false,
              },
            ),
          );
          if (address.id != null) {
            await _publishAddress(address.id!);
          }
        }
      }
    } catch (e) {
      print('Error unsetting default addresses: $e');
      // Non-critical error, continue
    }
  }

  // Helper: Publish address
  Future<void> _publishAddress(String addressId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishAddress),
          variables: {'id': addressId},
        ),
      );
    } catch (e) {
      print('Error publishing address: $e');
      // Non-critical error
    }
  }
}

// Global instance
final addressService = AddressService();
