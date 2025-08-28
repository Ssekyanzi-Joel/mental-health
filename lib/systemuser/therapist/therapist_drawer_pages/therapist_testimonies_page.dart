import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


/// ------------------------------
/// Therapist Post Testimony Page
/// ------------------------------
class TherapistPostTestimonyPage extends StatefulWidget {
  const TherapistPostTestimonyPage({super.key});

  @override
  State<TherapistPostTestimonyPage> createState() =>
      _TherapistPostTestimonyPageState();
}

class _TherapistPostTestimonyPageState
    extends State<TherapistPostTestimonyPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  bool _loading = false;

  Future<void> _pickMedia() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _mediaFile = File(pickedImage.path);
        _isVideo = false;
      });
      return;
    }
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _mediaFile = File(pickedVideo.path);
        _isVideo = true;
      });
    }
  }

  Future<void> _uploadTestimony() async {
    if (_textController.text.isEmpty && _mediaFile == null) return;

    setState(() => _loading = true);

    String? mediaUrl;
    if (_mediaFile != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('testimonies/$fileName');
      await ref.putFile(_mediaFile!);
      mediaUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('testimonies').add({
      'name': 'Therapist',
      'text': _textController.text,
      'mediaUrl': mediaUrl,
      'isVideo': _isVideo,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _textController.clear();
      _mediaFile = null;
      _isVideo = false;
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Testimony posted successfully ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist - Post Testimony"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Write a testimony...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickMedia,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Add Media"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _uploadTestimony,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Post"),
                ),
              ],
            ),
            if (_mediaFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: !_isVideo
                    ? Image.file(_mediaFile!, height: 150)
                    : const Icon(Icons.videocam, size: 80, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
