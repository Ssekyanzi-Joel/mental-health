import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _gender;
  String? _role;
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store additional user info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _gender,
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else {
        message = 'Registration failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // First + Last Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter first name' : null,
                    decoration: const InputDecoration(
                      hintText: "First Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter last name' : null,
                    decoration: const InputDecoration(
                      hintText: "Last Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value!.isEmpty ? 'Enter your email' : null,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Country + City
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter country' : null,
                    decoration: const InputDecoration(
                      hintText: "Country",
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter city' : null,
                    decoration: const InputDecoration(
                      hintText: "City",
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value!.isEmpty ? 'Enter phone number' : null,
              decoration: const InputDecoration(
                hintText: "Phone",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              initialValue: _gender,
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _gender = val),
              validator: (val) => val == null ? 'Select gender' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.wc),
                hintText: 'Gender',
              ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Role Dropdown
            DropdownButtonFormField<String>(
              initialValue: _role,
              items: ['Admin', 'User', 'Therapist']
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _role = val),
              validator: (val) => val == null ? 'Select role' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.verified_user),
                hintText: 'Role',
              ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Password
            TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              obscureText: true,
              validator: (value) => value!.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
              decoration: const InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              validator: (value) =>
                  value!.isEmpty ? 'Confirm your password' : null,
              decoration: const InputDecoration(
                hintText: "Confirm Password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: defaultPadding),

            // Sign Up Button
            ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text("SIGN UP"),
            ),

            const SizedBox(height: defaultPadding),

            // Already have account
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
