import 'package:flutter/material.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isValidIndianMobile(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }

  void _sendOtp() {
    if (!widget.formKey.currentState!.validate()) return;

    setState(() {
      _otpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your mobile number.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Mobile number',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your mobile number';
              }
              if (!_isValidIndianMobile(value)) {
                return 'Enter a valid Indian mobile number (10 digits starting with 6-9)';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          if (!_otpSent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendOtp,
                child: const Text('Send OTP'),
              ),
            ),
          if (_otpSent) ...[
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length < 4) {
                  return 'OTP must be at least 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: defaultPadding),
          ],
        ],
      ),
    );
  }
}
