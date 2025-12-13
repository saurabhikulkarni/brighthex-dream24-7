import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class Address {
  final String id;
  final String name;
  final String address;
  final String city;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.isDefault,
  });
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late List<Address> addresses;

  @override
  void initState() {
    super.initState();
    addresses = [
      Address(
        id: "1",
        name: "Home",
        address: "123 Main Street, Apt 4B",
        city: "New York, NY 10001",
        zipCode: "10001",
        isDefault: true,
      ),
      Address(
        id: "2",
        name: "Work",
        address: "456 Business Ave, Suite 200",
        city: "New York, NY 10002",
        zipCode: "10002",
        isDefault: false,
      ),
      Address(
        id: "3",
        name: "Family",
        address: "789 Oak Road",
        city: "Boston, MA 02101",
        zipCode: "02101",
        isDefault: false,
      ),
    ];
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Add new address")),
              );
            },
          ),
        ],
      ),
      body: addresses.isEmpty
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
                              address.name,
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
                                child: Text(
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
                          address.address,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${address.city} ${address.zipCode}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text("Edit"),
                            ),
                            ElevatedButton(
                              onPressed: () => _deleteAddress(index),
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
