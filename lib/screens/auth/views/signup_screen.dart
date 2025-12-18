import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/user_service.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic _signUpFormState;
  bool _privacyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/welcome.jpg",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let’s get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    onFormCreated: (form) {
                      _signUpFormState = form;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                        },
                        value: _privacyAccepted,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (!_privacyAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please accept the terms and privacy policy'),
                          ),
                        );
                        return;
                      }

                      final name = _signUpFormState.getUserName();
                      final phone = _signUpFormState.getVerifiedPhone();
                      
                      if (phone == null || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please verify your phone number with OTP'),
                          ),
                        );
                        return;
                      }

                      try {
                        // Check if user already exists with this phone number
                        print('Checking if user exists with phone: $phone');
                        final UserService userService = UserService();
                        final existingUser = await userService.getUserByUsername(phone);
                        
                        if (existingUser != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Account already exists with this phone number'),
                                backgroundColor: Colors.orange,
                                action: SnackBarAction(
                                  label: 'Login',
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, logInScreenRoute);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                          print('User already exists: ${existingUser.id}');
                          return;
                        }

                        print('User does not exist, proceeding with account creation');

                        // Extract first and last name from full name
                        final nameParts = name.split(' ');
                        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
                        
                        // Call GraphQL mutation to create user and get their ID
                        final graphQLClient = GraphQLService.getClient();
                        final MutationOptions options = MutationOptions(
                          document: gql(GraphQLQueries.createUser),
                          variables: {
                            'firstName': firstName,
                            'lastName': lastName,
                            'username': phone,
                            'password': '', // Can be empty for phone-based signup
                          },
                        );
                        
                        print('Creating user with phone: $phone, firstName: $firstName, lastName: $lastName');
                        final QueryResult result = await graphQLClient.mutate(options);
                        
                        if (result.hasException) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${result.exception}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          print('GraphQL Error: ${result.exception}');
                          return;
                        }
                        
                        // Extract userId from response
                        final userId = result.data?['createUserDetail']?['id'];
                        print('User created with ID: $userId, Response: ${result.data}');

                        // Immediately publish the new user (Hygraph returns only published content in queries)
                        if (userId != null && userId.isNotEmpty) {
                          try {
                            final publishResult = await graphQLClient.mutate(
                              MutationOptions(
                                document: gql(GraphQLQueries.publishUser),
                                variables: {'id': userId},
                              ),
                            );
                            if (publishResult.hasException) {
                              print('Warning: publishUser exception: ${publishResult.exception}');
                            } else {
                              print('User published: $userId');
                            }
                          } catch (e) {
                            print('Warning: Exception publishing user: $e');
                          }
                        }
                        
                        if (userId != null && userId.isNotEmpty) {
                          // Save login session with userId from Hygraph
                          final authService = AuthService();
                          await authService.saveLoginSession(
                            phone: phone,
                            name: name,
                            phoneVerified: true,
                            userId: userId,
                          );
                          
                          print('Login session saved for user: $userId');
                          
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(
                              context, entryPointScreenRoute);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Could not create user account'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          print('Error: userId is null or empty');
                        }
                      } catch (e) {
                        print('Exception in signup: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Continue"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
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
