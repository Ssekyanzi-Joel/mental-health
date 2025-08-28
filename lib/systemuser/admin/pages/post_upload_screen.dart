import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _mediaFile;
  String? _mediaType; // "image" or "video"
  bool _isLoading = false;

  Future<void> _pickMedia(bool isImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = isImage ? "image" : "video";
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_textController.text.isEmpty && _mediaFile == null) return;

    setState(() => _isLoading = true);

    String mediaUrl = '';
    if (_mediaFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(_mediaFile!);
      mediaUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'authorName': 'Dr. Jane Doe', // Replace with logged-in user's name
      'text': _textController.text,
      'mediaUrl': mediaUrl,
      'mediaType': _mediaType ?? 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isLoading = false;
      _textController.clear();
      _mediaFile = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            if (_mediaFile != null)
              (_mediaType == "image")
                  ? Image.file(_mediaFile!, height: 200)
                  : Text("Video selected"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(true),
                  icon: Icon(Icons.image),
                  label: Text("Add Image"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(false),
                  icon: Icon(Icons.videocam),
                  label: Text("Add Video"),
                ),
              ],
            ),
            Spacer(),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadPost,
                    child: Text("Post"),
                  )
          ],
        ),
      ),
    );
  }
}
