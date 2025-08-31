import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

// Define a custom color palette
const Color primaryGreen = Color(0xFF4CAF50); // A vibrant green
const Color lightGreen = Color(0xFFC8E6C9); // A soft, light green
const Color darkGreen = Color(0xFF2E7D32); // A dark green for text/icons
const Color softShadow = Color(0x33000000); // Soft black shadow with opacity

// Helper widget to play videos from a local File (for Android/iOS)
class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;
  const VideoPlayerWidget(this.videoFile, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _controller.play();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator(color: primaryGreen));
  }
}

// Helper widget to play videos from bytes (for Web)
class VideoPlayerWidgetFromBytes extends StatefulWidget {
  final Uint8List videoBytes;
  const VideoPlayerWidgetFromBytes(this.videoBytes, {super.key});

  @override
  State<VideoPlayerWidgetFromBytes> createState() =>
      _VideoPlayerWidgetFromBytesState();
}

class _VideoPlayerWidgetFromBytesState
    extends State<VideoPlayerWidgetFromBytes> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.dataFromBytes(widget.videoBytes, mimeType: 'video/mp4'),
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _controller.play();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator(color: primaryGreen));
  }
}

// Helper widget to play videos from a network URL
class VideoFromNetwork extends StatefulWidget {
  final String videoUrl;
  const VideoFromNetwork({super.key, required this.videoUrl});

  @override
  State<VideoFromNetwork> createState() => _VideoFromNetworkState();
}

class _VideoFromNetworkState extends State<VideoFromNetwork> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator(color: primaryGreen));
  }
}

// Reusable custom card widget for the testimonies
class TestimonyCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TestimonyCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isVideo = data['isVideo'] ?? false;
    final String? mediaUrl = data['mediaUrl'];

    return Card(
      elevation: 8,
      shadowColor: softShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mediaUrl != null)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: isVideo
                    ? VideoFromNetwork(videoUrl: mediaUrl)
                    : Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data['text'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 10) // Format date
                      : '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Main page widget
class TestimoniesPage extends StatefulWidget {
  const TestimoniesPage({super.key});

  @override
  State<TestimoniesPage> createState() => _TestimoniesPageState();
}

class _TestimoniesPageState extends State<TestimoniesPage> {
  final _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedMedia;
  Uint8List? _selectedMediaBytes; // To store bytes for web preview
  bool _isVideo = false;
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickMedia() async {
    final pickedFile = await _picker
        .pickMedia(); // Use pickMedia() for cross-platform support
    if (pickedFile != null) {
      final String mimeType = pickedFile.mimeType ?? '';
      setState(() {
        if (kIsWeb) {
          _selectedMediaBytes = null; // Clear old data
          _selectedMedia = null; // Clear old data
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _selectedMediaBytes = bytes;
            });
          });
        } else {
          _selectedMedia = File(pickedFile.path);
          _selectedMediaBytes = null;
        }
        _isVideo = mimeType.startsWith('video/');
      });
    }
  }

  Future<void> _uploadTestimony() async {
    if (_textController.text.isEmpty &&
        _selectedMedia == null &&
        _selectedMediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add text or a media file to post.'),
        ),
      );
      return;
    }

    String? mediaUrl;
    if (_selectedMedia != null || _selectedMediaBytes != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('testimonies')
          .child(fileName);

      if (kIsWeb) {
        await ref.putData(_selectedMediaBytes!);
      } else {
        await ref.putFile(_selectedMedia!);
      }
      mediaUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('testimonies').add({
      'name': 'Admin/Therapist',
      'text': _textController.text,
      'mediaUrl': mediaUrl,
      'isVideo': _isVideo,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _selectedMedia = null;
      _selectedMediaBytes = null;
      _textController.clear();
      _isVideo = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testimonies'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Upload section for Admin/Therapist
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 8,
            shadowColor: softShadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post a Testimony',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Write a testimony...',
                      labelStyle: TextStyle(color: darkGreen),
                      hintText: 'Share a positive story here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: lightGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: lightGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryGreen,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 4,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickMedia,
                          icon: const Icon(
                            Icons.add_photo_alternate,
                            color: primaryGreen,
                          ),
                          label: const Text('Add Media'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: darkGreen,
                            backgroundColor: lightGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _uploadTestimony,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Post'),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedMedia != null || _selectedMediaBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _isVideo
                            ? AspectRatio(
                                aspectRatio: 16 / 9,
                                child: kIsWeb
                                    ? VideoPlayerWidgetFromBytes(
                                        _selectedMediaBytes!,
                                      )
                                    : VideoPlayerWidget(_selectedMedia!),
                              )
                            : kIsWeb
                            ? Image.memory(
                                _selectedMediaBytes!,
                                height: 150,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.file(
                                _selectedMedia!,
                                height: 150,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List of testimonies
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('testimonies')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryGreen),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No testimonies posted yet.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return TestimonyCard(data: data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
