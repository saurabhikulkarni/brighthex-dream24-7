import 'package:flutter/material.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/address_service.dart';
import 'package:shop/services/user_service.dart';

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
  
  bool _isLoading = false;

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

  Future<void> _saveAddress() async {
    // Validate required fields
    if (fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        roadNameController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create address model
      final address = AddressModel(
        id: widget.addressId,
        userId: userId,
        fullName: fullNameController.text,
        phoneNumber: phoneController.text,
        pincode: pincodeController.text,
        addressLine1: houseNumberController.text,
        addressLine2: roadNameController.text,
        city: cityController.text,
        state: stateController.text,
        country: 'India',
        isDefault: false, // You can add a checkbox for this if needed
      );

      // Save address using service
      if (widget.addressId != null) {
        // Update existing address
        await addressService.updateAddress(address);
      } else {
        // Create new address
        await addressService.createAddress(address);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Return success
      Navigator.pop(context, {'success': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.addressId == null 
              ? 'Address saved successfully' 
              : 'Address updated successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(widget.addressId == null ? 'Save Address' : 'Update Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
