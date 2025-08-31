import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminTherapyPage extends StatefulWidget {
  const AdminTherapyPage({super.key});

  @override
  State<AdminTherapyPage> createState() => _AdminTherapyPageState();
}

class _AdminTherapyPageState extends State<AdminTherapyPage> {
  // Theme colors matching your app
  static const Color primaryGreen = Color(0xFF19351E);
  static const Color accentGreen = Color(0xFF3D6B42);
  // ignore: unused_field
  static const Color darkGreen = Color(0xFF0F1F12);
  static const Color creamWhite = Color(0xFFF7F5F3);
  static const Color lightCream = Color(0xFFE8F5E8);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  XFile? _selectedImage; // works on both mobile & web
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // compress for smaller size
    );

    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  /// Upload image to Firebase Storage (handles web & mobile)
  Future<String?> _uploadImage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("therapy_images")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      if (kIsWeb) {
        // On web, upload using bytes
        final bytes = await image.readAsBytes();
        await ref.putData(bytes);
      } else {
        // On mobile, upload using File
        await ref.putFile(File(image.path));
      }

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  /// Save post to Firestore
  Future<void> _postContent() async {
    if (_titleController.text.isEmpty || _notesController.text.isEmpty) {
      _showSnackBar("Title and notes cannot be empty", isError: true);
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar("Please select an image", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image
      String? mediaUrl = await _uploadImage(_selectedImage!);

      // Save to Firestore
      await FirebaseFirestore.instance.collection("education").add({
        "title": _titleController.text.trim(),
        "notes": _notesController.text.trim(),
        "mediaUrl": mediaUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Reset form
      setState(() {
        _isLoading = false;
        _titleController.clear();
        _notesController.clear();
        _selectedImage = null;
      });

      _showSnackBar("Post added successfully", isError: false);
    } catch (e) {
      debugPrint("Firestore error: $e");
      setState(() => _isLoading = false);
      _showSnackBar("Error adding post: $e", isError: true);
    }
  }

  /// Show styled snackbar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Image preview that works on Web + Mobile
  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb
                ? FutureBuilder(
                    future: _selectedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: lightCream,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          ),
                        );
                      }
                    },
                  )
                : Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: primaryGreen),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryGreen),
          labelStyle: TextStyle(color: primaryGreen.withOpacity(0.8)),
          hintStyle: TextStyle(color: primaryGreen.withOpacity(0.5)),
          filled: true,
          fillColor: lightCream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryGreen.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          "Admin Therapy Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lightCream, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Therapy Content",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Share educational content with your community",
                          style: TextStyle(color: primaryGreen, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form fields
            _buildInputField(
              controller: _titleController,
              label: "Title",
              icon: Icons.title,
              hint: "Enter a compelling title...",
            ),

            _buildInputField(
              controller: _notesController,
              label: "Notes",
              icon: Icons.description,
              maxLines: 5,
              hint: "Share your therapy insights and guidance...",
            ),

            // Image section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryGreen.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_selectedImage == null) ...[
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: primaryGreen.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Add an Image",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload an inspiring or educational image",
                      style: TextStyle(
                        color: primaryGreen.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildImagePreview(),
                  ],

                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(
                      _selectedImage == null
                          ? Icons.add_photo_alternate
                          : Icons.edit,
                    ),
                    label: Text(
                      _selectedImage == null ? "Pick Image" : "Change Image",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Post button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Publishing Post...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _postContent,
                      icon: const Icon(Icons.publish),
                      label: const Text(
                        "Publish Post",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: primaryGreen.withOpacity(0.3),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
