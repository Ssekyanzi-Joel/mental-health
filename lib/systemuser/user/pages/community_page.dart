import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mind_aware_application/systemuser/user/drawer_pages/testimonies_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  // Discord-inspired calming color palette for mental health
  static const Color primaryBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color mainThemeColor = Color(0xFF2D5A3D);
  static const Color accentGreen = Color(0xFF6BCF7F);
  static const Color lightGreen = Color(0xFF9CDBA6);
  static const Color softBlue = Color(0xFF87CEEB);
  static const Color softPurple = Color(0xFFB19CD9);
  static const Color softOrange = Color(0xFFFFB347);
  static const Color creamWhite = Color(0xFFFFFDF7);

  final TextEditingController _postController = TextEditingController();
  File? _mediaFile;
  String? _mediaType;
  bool _isPosting = false;
  bool _isPostExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _togglePostExpanded() {
    setState(() {
      _isPostExpanded = !_isPostExpanded;
    });
  }

  // Pick image or video
  Future<void> _pickMedia(bool isImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = isImage ? "image" : "video";
      });
    }
  }

  // Upload post to Firebase
  Future<void> _uploadPost() async {
    if (_postController.text.trim().isEmpty && _mediaFile == null) {
      _showSnackBar("Please add some content to your post", Icons.warning);
      return;
    }

    setState(() => _isPosting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      final userData = userDoc.data() ?? {};

      String? mediaUrl;
      if (_mediaFile != null) {
        final ref = FirebaseStorage.instance.ref().child(
          "posts/${DateTime.now().millisecondsSinceEpoch}",
        );
        await ref.putFile(_mediaFile!);
        mediaUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection("posts").add({
        "userId": user.uid,
        "firstName": userData["firstName"] ?? "",
        "lastName": userData["lastName"] ?? "",
        "role": userData["role"] ?? "User",
        "content": _postController.text.trim(),
        "mediaUrl": mediaUrl,
        "mediaType": _mediaType ?? "text",
        "likes": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _postController.clear();
        _mediaFile = null;
        _mediaType = null;
        _isPostExpanded = false;
      });

      _showSnackBar("Post shared successfully!", Icons.check_circle);
    } catch (e) {
      _showSnackBar("Failed to share post", Icons.error);
    }

    setState(() => _isPosting = false);
  }

  // Toggle like
  Future<void> _toggleLike(String postId, List likes) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection("posts").doc(postId);

    try {
      if (likes.contains(uid)) {
        await ref.update({
          "likes": FieldValue.arrayRemove([uid]),
        });
      } else {
        await ref.update({
          "likes": FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      _showSnackBar("Failed to update like", Icons.error);
    }
  }

  // Add Comment
  Future<void> _addComment(String postId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    final userData = userDoc.data() ?? {};

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .add({
            "userId": user.uid,
            "firstName": userData["firstName"] ?? "",
            "lastName": userData["lastName"] ?? "",
            "text": text,
            "createdAt": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      _showSnackBar("Failed to add comment", Icons.error);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  void _showCommentsModal(String postId) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: mainThemeColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: mainThemeColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: accentGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Comments",
                      style: TextStyle(
                        color: mainThemeColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: mainThemeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: mainThemeColor.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Divider(
                color: mainThemeColor.withOpacity(0.1),
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              const SizedBox(height: 16),

              // Comments list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .doc(postId)
                      .collection("comments")
                      .orderBy("createdAt", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: accentGreen,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    final comments = snapshot.data!.docs;

                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: accentGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: accentGreen.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No comments yet",
                              style: TextStyle(
                                color: mainThemeColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Start the conversation and share your thoughts",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: mainThemeColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final data =
                            comments[index].data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: accentGreen.withOpacity(
                                      0.2,
                                    ),
                                    child: Text(
                                      "${data['firstName']?[0] ?? ''}${data['lastName']?[0] ?? ''}",
                                      style: TextStyle(
                                        color: mainThemeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                                          style: TextStyle(
                                            color: mainThemeColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _formatTimeAgo(data['createdAt']),
                                          style: TextStyle(
                                            color: mainThemeColor.withOpacity(
                                              0.5,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data['text'] ?? "",
                                style: TextStyle(
                                  color: mainThemeColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Comment input
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                decoration: BoxDecoration(
                  color: cardBackground,
                  border: Border(
                    top: BorderSide(
                      color: mainThemeColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accentGreen.withOpacity(0.2),
                      child: Icon(
                        Icons.person_rounded,
                        color: mainThemeColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: mainThemeColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: commentController,
                          style: TextStyle(color: mainThemeColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Add a supportive comment...",
                            hintStyle: TextStyle(
                              color: mainThemeColor.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (commentController.text.trim().isNotEmpty) {
                            _addComment(postId, commentController.text.trim());
                            commentController.clear();
                          }
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d";
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  // Discord-inspired header section
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [creamWhite, primaryBackground],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    color: mainThemeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Community",
                        style: TextStyle(
                          color: mainThemeColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Connect, share, and support each other",
                        style: TextStyle(
                          color: mainThemeColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Support groups section
  Widget _buildSupportGroups() {
    final groups = [
      {
        "name": "Anxiety Support",
        "members": "2.3k",
        "description": "Safe space for anxiety discussions",
        "color": softBlue,
        "icon": "🫂",
      },
      {
        "name": "Depression Care",
        "members": "1.8k",
        "description": "Understanding and healing together",
        "color": softPurple,
        "icon": "💜",
      },
      {
        "name": "Mindfulness Circle",
        "members": "3.1k",
        "description": "Daily mindfulness practices",
        "color": accentGreen,
        "icon": "🧘",
      },
      {
        "name": "Stress Relief",
        "members": "1.5k",
        "description": "Coping strategies and support",
        "color": softOrange,
        "icon": "🌅",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Support Groups",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < groups.length - 1 ? 16 : 0,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (group['color'] as Color).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (group['color'] as Color).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            group['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (group['color'] as Color).withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${group['members']} members",
                                style: TextStyle(
                                  color: group['color'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        group['name'] as String,
                        style: TextStyle(
                          color: mainThemeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          group['description'] as String,
                          style: TextStyle(
                            color: mainThemeColor.withOpacity(0.6),
                            fontSize: 12,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Community feed section
  Widget _buildCommunityFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Community Feed",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: mainThemeColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_rounded, color: accentGreen, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCreatePostCard(),
          const SizedBox(height: 20),
          _buildFeedPosts(),
        ],
      ),
    );
  }

  // Create post card
  Widget _buildCreatePostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentGreen.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accentGreen.withOpacity(0.2),
                child: Icon(
                  Icons.person_rounded,
                  color: mainThemeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _togglePostExpanded,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: mainThemeColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "Share your thoughts with the community...",
                      style: TextStyle(
                        color: mainThemeColor.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isPostExpanded) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: primaryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: mainThemeColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _postController,
                maxLines: 4,
                style: TextStyle(color: mainThemeColor, fontSize: 14),
                decoration: const InputDecoration(
                  hintText:
                      "What's on your mind? Share your experience, ask for support, or offer encouragement...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMedia(true),
                    icon: const Icon(Icons.image_rounded, size: 18),
                    label: const Text("Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softBlue.withOpacity(0.1),
                      foregroundColor: softBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: softBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isPosting ? null : _uploadPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Share"),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Feed posts
  Widget _buildFeedPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .orderBy("createdAt", descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: posts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildPostCard(doc.id, data);
          }).toList(),
        );
      },
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: accentGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome to the Community!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: mainThemeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your story and connect with others on their mental health journey.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mainThemeColor.withOpacity(0.6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Post card
  Widget _buildPostCard(String postId, Map<String, dynamic> data) {
    final likes = List<String>.from(data['likes'] ?? []);
    final isLiked = likes.contains(FirebaseAuth.instance.currentUser?.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainThemeColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: mainThemeColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accentGreen.withOpacity(0.2),
                child: Text(
                  "${data['firstName']?[0] ?? ''}${data['lastName']?[0] ?? ''}",
                  style: TextStyle(
                    color: mainThemeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                      style: TextStyle(
                        color: mainThemeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(data['createdAt']),
                      style: TextStyle(
                        color: mainThemeColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          if (data['content']?.isNotEmpty == true)
            Text(
              data['content'],
              style: TextStyle(
                color: mainThemeColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          // Media
          if (data['mediaUrl'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data['mediaUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(postId, likes),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? accentGreen.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLiked
                          ? accentGreen
                          : mainThemeColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? accentGreen
                            : mainThemeColor.withOpacity(0.6),
                        size: 16,
                      ),
                      if (likes.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          "${likes.length}",
                          style: TextStyle(
                            color: isLiked
                                ? accentGreen
                                : mainThemeColor.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showCommentsModal(postId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: mainThemeColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: mainThemeColor.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Comment",
                        style: TextStyle(
                          color: mainThemeColor.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Clean header section
          SliverToBoxAdapter(child: _buildHeaderSection()),

          // Support Groups Section
          SliverToBoxAdapter(child: _buildSupportGroups()),

          // Community Feed
          SliverToBoxAdapter(child: _buildCommunityFeed()),
        ],
      ),
    );
  }
}
