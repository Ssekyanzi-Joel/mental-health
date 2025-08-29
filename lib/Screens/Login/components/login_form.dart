// lib/Screens/Login/components/login_form.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_aware_application/Screens/Signup/signup_screen.dart';
import 'package:mind_aware_application/components/already_have_an_account_acheck.dart';
import 'package:mind_aware_application/constants.dart';
import 'package:mind_aware_application/systemuser/admin/bottom_and_drawer_shell.dart';
import 'package:mind_aware_application/systemuser/therapist/therapist_bottom_and_drawer_shell.dart';
import 'package:mind_aware_application/systemuser/user/bottom_and_drawer_shell.dart';



class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
            code: 'no-user-data', message: 'User data not found.');
      }

      String role = userDoc['role'];

      // Navigate based on role
      Widget destination;
      if (role == 'Admin') {
        destination = const Admindasborad();
      } else if (role == 'User') {
        destination = const HomeShell();
      } else if (role == 'Therapist') {
        destination = const TherapistBottom();
      } else {
        throw FirebaseAuthException(
            code: 'invalid-role', message: 'Invalid role assigned.');
      }

      // Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'no-user-data') {
        message = 'User data not found. Contact admin.';
      } else if (e.code == 'invalid-role') {
        message = 'Invalid role assigned. Contact admin.';
      } else {
        message = 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 600;

    InputDecoration inputDecoration(String hint, IconData icon) =>
        InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Icon(icon),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
        );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              validator: (value) =>
                  value!.isEmpty ? 'Enter your email' : null,
              decoration: inputDecoration('Email', Icons.email),
            ),
          ),

          // Password
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              cursorColor: kPrimaryColor,
              validator: (value) =>
                  value!.isEmpty ? 'Enter your password' : null,
              decoration: inputDecoration('Password', Icons.lock),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Login Button
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginUser,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Login"),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Sign Up link
          AlreadyHaveAnAccountCheck(
            login: true,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
