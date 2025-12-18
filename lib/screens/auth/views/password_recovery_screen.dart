import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'dart:async';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  int _currentStep = 0; // 0: Phone, 1: OTP, 2: New Password
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  Timer? _resendTimer;
  int _secondsLeft = 0;
  static const int _resendDuration = 30;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    if (!_isValidIndianMobile(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian mobile number (10 digits)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });

    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to ${_phoneController.text}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty || _otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verified successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetPassword() {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Password reset successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to login
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Enter Phone Number
            if (_currentStep == 0) ...[
              Text(
                "Enter your mobile number",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll send you an OTP to verify your identity",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter your mobile number",
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: "+91 ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text("Send OTP"),
                ),
              ),
            ]
            // Step 2: Verify OTP
            else if (_currentStep == 1) ...[
              Text(
                "Enter verification code",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "We sent a code to +91 ${_phoneController.text}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter 4-6 digit OTP",
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  counterText: '',
                ),
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
                    style: TextStyle(
                      color: _secondsLeft == 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text("Verify OTP"),
                ),
              ),
            ]
            // Step 3: Create New Password
            else if (_currentStep == 2) ...[
              Text(
                "Create new password",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Make sure it's at least 6 characters long",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: "Confirm password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Reset Password"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
