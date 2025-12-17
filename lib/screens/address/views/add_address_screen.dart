import 'package:flutter/material.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/constants.dart';

class AddAddressScreen extends StatefulWidget {
  final String? addressId;
  final String? fullName;
  final String? emailId;
  final String? phoneNumber;
  final String? houseNumber;
  final String? roadName;
  final String? landmark;
  final String? pincode;
  final String? city;
  final String? state;

  const AddAddressScreen({
    super.key,
    this.addressId,
    this.fullName,
    this.emailId,
    this.phoneNumber,
    this.houseNumber,
    this.roadName,
    this.landmark,
    this.pincode,
    this.city,
    this.state,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController houseNumberController;
  late TextEditingController roadNameController;
  late TextEditingController landmarkController;
  late TextEditingController pincodeController;
  late TextEditingController cityController;
  late TextEditingController stateController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName);
    emailController = TextEditingController(text: widget.emailId);
    phoneController = TextEditingController(text: widget.phoneNumber);
    houseNumberController = TextEditingController(text: widget.houseNumber);
    roadNameController = TextEditingController(text: widget.roadName);
    landmarkController = TextEditingController(text: widget.landmark);
    pincodeController = TextEditingController(text: widget.pincode);
    cityController = TextEditingController(text: widget.city);
    stateController = TextEditingController(text: widget.state);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    houseNumberController.dispose();
    roadNameController.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _saveAddress() {
    // Validate required fields
    if (fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        roadNameController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Return address data to previous screen
    Navigator.pop(context, {
      'fullName': fullNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'houseNumber': houseNumberController.text,
      'roadName': roadNameController.text,
      'landmark': landmarkController.text,
      'pincode': pincodeController.text,
      'city': cityController.text,
      'state': stateController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow back button to work properly
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.addressId == null ? 'Add Address' : 'Edit Address'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Details Section
                Text(
                  'Basic Details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: emailController,
                  label: 'Email ID',
                  hint: 'Enter your email id',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                // Address Section
                Text(
                  'Address',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: houseNumberController,
                  label: 'House No/ Building Name',
                  hint: 'Enter your House No/ Building Name',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: roadNameController,
                  label: 'Road Name/ Area/ Colony',
                  hint: 'Enter your Road Name/ Area/ Colony',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: landmarkController,
                  label: 'Landmark (Optional)',
                  hint: 'Enter your Landmark (Optional)',
                ),
                const SizedBox(height: defaultPadding),
                _buildTextField(
                  controller: pincodeController,
                  label: 'Pincode',
                  hint: 'Enter your Pincode',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: cityController,
                        label: 'City',
                        hint: 'Enter your City',
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildTextField(
                        controller: stateController,
                        label: 'State',
                        hint: 'Enter State',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding * 2),
                // Save Button
                GradientButton(
                  onPressed: _saveAddress,
                  child: const Text('Save Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
