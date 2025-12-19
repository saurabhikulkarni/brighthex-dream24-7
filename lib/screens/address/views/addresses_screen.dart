import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

class Address {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String houseNumber;
  final String roadName;
  final String landmark;
  final String pincode;
  final String city;
  final String state;
  bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    this.email = '',
    this.phone = '',
    this.houseNumber = '',
    this.roadName = '',
    this.landmark = '',
    required this.pincode,
    required this.city,
    this.state = '',
    this.isDefault = false,
  });

  // For backward compatibility with old Address constructor
  Address.simple({
    required String id,
    required String name,
    required String address,
    required String city,
    required String zipCode,
    required bool isDefault,
  })  : id = id,
        fullName = name,
        email = '',
        phone = '',
        houseNumber = address,
        roadName = '',
        landmark = '',
        pincode = zipCode,
        city = city,
        state = '',
        isDefault = isDefault;
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late List<Address> addresses;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _isLoading = true;
    });
    // Load addresses from GraphQL or local mock data
    addresses = [
      Address(
        id: "1",
        fullName: "John Doe",
        email: "john@example.com",
        phone: "+1 (555) 123-4567",
        houseNumber: "123",
        roadName: "Main Street, Apt 4B",
        landmark: "Near Central Park",
        pincode: "10001",
        city: "New York",
        state: "NY",
        isDefault: true,
      ),
      Address(
        id: "2",
        fullName: "John Doe",
        email: "john@example.com",
        phone: "+1 (555) 123-4567",
        houseNumber: "456",
        roadName: "Business Ave, Suite 200",
        landmark: "Business District",
        pincode: "10002",
        city: "New York",
        state: "NY",
        isDefault: false,
      ),
      Address(
        id: "3",
        fullName: "John Doe",
        email: "john@example.com",
        phone: "+1 (555) 123-4567",
        houseNumber: "789",
        roadName: "Oak Road",
        landmark: "Residential Area",
        pincode: "02101",
        city: "Boston",
        state: "MA",
        isDefault: false,
      ),
    ];
    setState(() {
      _isLoading = false;
    });
  }

  void _setDefaultAddress(String addressId) {
    setState(() {
      for (var address in addresses) {
        address.isDefault = address.id == addressId;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Default address updated")),
    );
  }

  void _deleteAddress(String addressId) {
    setState(() {
      addresses.removeWhere((address) => address.id == addressId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, addAddressScreenRoute).then((result) {
                if (result != null && result is Map && result['success'] == true) {
                  _loadAddresses(); // Reload addresses from GraphQL
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        "No addresses saved",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              address.fullName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Default",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          '${address.houseNumber}, ${address.roadName}, ${address.city}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (address.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Phone: ${address.phone}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!address.isDefault)
                              ElevatedButton(
                                onPressed: () => _setDefaultAddress(address.id),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text("Set as Default"),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  addAddressScreenRoute,
                                  arguments: {
                                    'addressId': address.id,
                                    'fullName': address.fullName,
                                    'phoneNumber': address.phone,
                                    'houseNumber': address.houseNumber,
                                    'roadName': address.roadName,
                                    'pincode': address.pincode,
                                    'city': address.city,
                                    'state': address.state,
                                  },
                                ).then((result) {
                                  if (result != null && result is Map && result['success'] == true) {
                                    _loadAddresses(); // Reload addresses
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text("Edit"),
                            ),
                            ElevatedButton(
                              onPressed: () => _deleteAddress(address.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
