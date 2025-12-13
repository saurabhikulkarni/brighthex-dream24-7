import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Sepide");
    _emailController = TextEditingController(text: "theflutterway@gmail.com");
    _phoneController = TextEditingController(text: "+1 (555) 123-4567");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Change photo")),
                );
              },
              child: const Text("Change Photo"),
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Text(
            "Full Name",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: "Enter your full name",
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "Email",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: "Enter your email",
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "Phone Number",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              hintText: "Enter your phone number",
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated")),
              );
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}
