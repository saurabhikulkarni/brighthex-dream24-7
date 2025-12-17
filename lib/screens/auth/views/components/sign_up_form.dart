import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/services/auth_service.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    this.onFormCreated,
  });

  final GlobalKey<FormState> formKey;
  final Function(_SignUpFormState)? onFormCreated;

  @override
  State<SignUpForm> createState() {
    final state = _SignUpFormState();
    onFormCreated?.call(state);
    return state;
  }
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  Timer? _resendTimer;
  int _secondsLeft = 0;
  static const int _resendDuration = 30;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  bool _isValidIndianMobile(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = _resendDuration;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  void _sendOtp() {
    if (!widget.formKey.currentState!.validate()) return;

    setState(() {
      _otpSent = true;
    });

    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your mobile number.')),
    );
  }

  Future<void> verifyPhoneAndGetNumber() async {
    if (!_otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please send OTP first'),
        ),
      );
      return;
    }

    if (_otpController.text.isEmpty || _otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
        ),
      );
      return;
    }

    // Mark phone as verified in AuthService
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    await AuthService().markPhoneVerified(phone);
  }

  String? getVerifiedPhone() {
    if (_otpSent && _otpController.text.isNotEmpty) {
      return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String getUserName() {
    return _nameController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Full name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _secondsLeft == 0 ? _sendOtp : null,
                child: Text(
                  _secondsLeft == 0
                      ? 'Resend OTP'
                      : 'Resend OTP (${_secondsLeft}s)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
