import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/user_service.dart';
import 'package:shop/route/route_constants.dart';

import '../../../../constants.dart';


class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    this.onFormCreated,
  });
  final GlobalKey<FormState> formKey;
  final Function(_LogInFormState)? onFormCreated;

  @override
  State<LogInForm> createState() {
    final state = _LogInFormState();
    onFormCreated?.call(state);
    return state;
  }
}

class _LogInFormState extends State<LogInForm> {
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
    // Validate Indian mobile number before sending OTP
    String phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indian mobile number (10 digits, starts with 6-9)
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Simulate sending OTP
    setState(() {
      _otpSent = true;
    });
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your mobile number.')),
    );
  }

  String? getVerifiedPhone() {
    if (_otpSent && _otpController.text.isNotEmpty && _otpController.text.length >= 4) {
      return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    }
    return null;
  }

  String getUserName() {
    return _nameController.text.trim();
  }

  Future<bool> saveLoginSession() async {
    final phone = getVerifiedPhone();
    if (phone != null) {
      final authService = AuthService();
      final name = getUserName();
      
      print('[LOGIN] Starting login session with phone: $phone');
      
      try {
        // Step 1: Check if account exists
        print('[LOGIN] Checking if account exists with phone: $phone');
        final existingUser = await UserService().getUserByUsername(phone);
        
        if (existingUser == null) {
          // Account does not exist
          print('[LOGIN] No account found with phone: $phone');
          if (!mounted) return false;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No account exists with this mobile number. Try sign-up to create account and then login.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Sign Up',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, signUpScreenRoute);
                },
              ),
            ),
          );
          return false;
        }
        
        // Step 2: Account exists, proceed with login
        print('[LOGIN] Account found! User ID: ${existingUser.id}');
        
        // Extract first and last name from existing user data if available
        final firstName = existingUser.firstName ?? '';
        final lastName = existingUser.lastName ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        print('[LOGIN] User name: $fullName, User ID: ${existingUser.id}');
        
        // Save login session with userId from Hygraph
        await authService.saveLoginSession(
          phone: phone,
          name: fullName.isNotEmpty ? fullName : name,
          phoneVerified: true,
          userId: existingUser.id,
        );
        
        print('[LOGIN] Login session saved successfully');
        return true;
      } catch (e) {
        print('[LOGIN] Exception in saveLoginSession: $e');
        if (!mounted) return false;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during login: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return false;
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
              // Remove non-numeric characters for validation
              String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
              
              // Validate Indian mobile number (10 digits, starts with 6-9)
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
                return 'Enter a valid Indian mobile number (10 digits starting with 6-9)';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          if (!_otpSent)
            GradientButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  _sendOtp();
                }
              },
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 1.5),
              child: const Text('Send OTP'),
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
