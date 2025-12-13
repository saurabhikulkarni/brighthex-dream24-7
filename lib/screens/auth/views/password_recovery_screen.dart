import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  int _currentStep = 0;
  late TextEditingController _emailController;
  late TextEditingController _codeController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            if (_currentStep == 0) ...[
              Text(
                "Enter your email address",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: defaultPadding),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  child: const Text("Send Code"),
                ),
              ),
            ] else if (_currentStep == 1) ...[
              Text(
                "Enter verification code",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "We sent a code to ${_emailController.text}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: defaultPadding),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: "Enter 6-digit code",
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 2;
                    });
                  },
                  child: const Text("Verify Code"),
                ),
              ),
            ] else if (_currentStep == 2) ...[
              Text(
                "Create new password",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: defaultPadding),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirm password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset successfully")),
                    );
                  },
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
