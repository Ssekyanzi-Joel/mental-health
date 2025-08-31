import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ------------------- Update Profile Page -------------------
class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UpdateProfilePage({super.key, required this.userData});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
      text: widget.userData['firstName'] ?? '',
    );
    lastNameController = TextEditingController(
      text: widget.userData['lastName'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    cityController = TextEditingController(text: widget.userData['city'] ?? '');
    countryController = TextEditingController(
      text: widget.userData['country'] ?? '',
    );
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'firstName': firstNameController.text.trim(),
              'lastName': lastNameController.text.trim(),
              'phone': phoneController.text.trim(),
              'city': cityController.text.trim(),
              'country': countryController.text.trim(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context); // Go back to profile page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (val) => val!.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (val) => val!.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (val) => val!.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: updateProfile,
                child: const Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
