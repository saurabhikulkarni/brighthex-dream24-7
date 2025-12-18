import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/components/gradient_button.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic _loginFormState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/welcome.jpg",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your mobile number and OTP.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    onFormCreated: (form) {
                      _loginFormState = form;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  GradientButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Attempt login and navigate only on success
                        final success = await _loginFormState.saveLoginSession();
                        if (!mounted) return;
                        if (success) {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              entryPointScreenRoute,
                              ModalRoute.withName(logInScreenRoute));
                        }
                      }
                    },
                    padding: const EdgeInsets.symmetric(vertical: defaultPadding / 1.5),
                    child: const Text("Log in"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
