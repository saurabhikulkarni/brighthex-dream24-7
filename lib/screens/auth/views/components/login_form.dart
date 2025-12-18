import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
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

  Future<void> saveLoginSession() async {
    final phone = getVerifiedPhone();
    if (phone != null) {
      final authService = AuthService();
      final name = getUserName();
      
      // Extract first and last name from full name
      final nameParts = name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      try {
        // Call GraphQL mutation to create/get user and get their ID
        final graphQLClient = GraphQLService.getClient();
        final MutationOptions options = MutationOptions(
          document: gql(GraphQLQueries.createUser),
          variables: {
            'firstName': firstName,
            'lastName': lastName,
            'username': phone,
            'password': '', // Can be empty for phone-based login
          },
        );
        
        final QueryResult result = await graphQLClient.mutate(options);
        
        if (result.hasException) {
          print('Error creating user: ${result.exception}');
          return;
        }
        
        // Extract userId from response
        final userId = result.data?['createUserDetail']?['id'];
        
        if (userId != null) {
          // Save login session with userId from Hygraph
          await authService.saveLoginSession(
            phone: phone,
            name: name,
            phoneVerified: true,
            userId: userId,
          );
        } else {
          print('Error: Could not extract user ID from response');
        }
      } catch (e) {
        print('Exception in saveLoginSession: $e');
      }
    }
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(passwordRecoveryScreenRoute);
                },
                child: const Text('Forgot Password?'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
