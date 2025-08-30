import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class TherapyPage extends StatelessWidget {
  final String therapistName;

  const TherapyPage({super.key, required this.therapistName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TherapyState(),
      child: _TherapyPageContent(therapistName: therapistName),
    );
  }
}

class TherapyState extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<XFile> selectedMedia = [];
  List<Uint8List> webMediaBytes = [];
  List<VideoPlayerController> videoControllers = [];
  bool isUploading = false;
  bool isCreatePostVisible = false;
  String selectedCategory = '';
  String sortBy = 'newest';
  String? editingPostId;
  Timer? autoSaveTimer;
  int totalPosts = 0;
  int totalViews = 0;
  int totalLikes = 0;

  void updateState({
    List<XFile>? newMedia,
    List<Uint8List>? newWebMediaBytes,
    List<VideoPlayerController>? newVideoControllers,
    bool? uploading,
    bool? createPostVisible,
    String? category,
    String? sort,
    String? editId,
    int? posts,
    int? views,
    int? likes,
  }) {
    selectedMedia = newMedia ?? selectedMedia;
    webMediaBytes = newWebMediaBytes ?? webMediaBytes;
    videoControllers = newVideoControllers ?? videoControllers;
    isUploading = uploading ?? isUploading;
    isCreatePostVisible = createPostVisible ?? isCreatePostVisible;
    selectedCategory = category ?? selectedCategory;
    sortBy = sort ?? sortBy;
    editingPostId = editId ?? editingPostId;
    totalPosts = posts ?? totalPosts;
    totalViews = views ?? totalViews;
    totalLikes = likes ?? totalLikes;
    notifyListeners();
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    titleController.text = prefs.getString('draft_title') ?? '';
    contentController.text = prefs.getString('draft_content') ?? '';
    selectedCategory = prefs.getString('draft_category') ?? '';
    notifyListeners();
  }

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', titleController.text);
    await prefs.setString('draft_content', contentController.text);
    await prefs.setString('draft_category', selectedCategory);
  }

  void startAutoSave() {
    autoSaveTimer?.cancel();
    autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (titleController.text.isNotEmpty ||
          contentController.text.isNotEmpty) {
        saveDraft();
      }
    });
  }

  Future<void> updateStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("education")
          .get();
      final posts = snapshot.docs.length;
      final views = snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc['views'] as int? ?? 0),
      );
      final likes = snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc['likes'] as int? ?? 0),
      );
      updateState(posts: posts, views: views, likes: likes);
    } catch (e) {
      print('Error updating stats: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    autoSaveTimer?.cancel();
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _TherapyPageContent extends StatefulWidget {
  final String therapistName;

  const _TherapyPageContent({required this.therapistName});

  @override
  State<_TherapyPageContent> createState() => _TherapyPageContentState();
}

class _TherapyPageContentState extends State<_TherapyPageContent>
    with TickerProviderStateMixin {
  // Bright Green Color Scheme
  static const Color primaryGreen = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue // Bright emerald
  static const Color accentGreen = Color.fromRGBO(
    34,
    197,
    94,
    1,
  ); // Vibrant green
  static const Color lightGreen = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color paleGreen = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color backgroundGreen = Color.fromRGBO(
    240,
    253,
    244,
    1,
  ); // Very light green
  static const Color cardGreen = Color.fromRGBO(
    255,
    255,
    255,
    1,
  ); // Pure white cards
  static const Color surfaceGreen = Color.fromRGBO(
    236,
    253,
    245,
    1,
  ); // Light mint surface
  static const Color darkText = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color mediumText = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue

  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'anxiety',
      'name': 'Anxiety',
      'icon': Icons.psychology,
      'color': Color.fromRGBO(251, 146, 60, 1), // Bright orange
    },
    {
      'id': 'depression',
      'name': 'Depression',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Color.fromRGBO(59, 130, 246, 1), // Bright blue
    },
    {
      'id': 'mindfulness',
      'name': 'Mindfulness',
      'icon': Icons.self_improvement,
      'color': Color.fromRGBO(147, 51, 234, 1), // Bright purple
    },
    {
      'id': 'stress',
      'name': 'Stress',
      'icon': Icons.flash_on,
      'color': Color.fromRGBO(239, 68, 68, 1), // Bright red
    },
    {
      'id': 'relationships',
      'name': 'Relationships',
      'icon': Icons.favorite,
      'color': Color.fromRGBO(236, 72, 153, 1), // Bright pink
    },
    {
      'id': 'self_care',
      'name': 'Self Care',
      'icon': Icons.spa,
      'color': Color.fromRGBO(20, 184, 166, 1), // Bright teal
    },
    {
      'id': 'coping',
      'name': 'Coping Skills',
      'icon': Icons.emoji_objects,
      'color': Color.fromRGBO(245, 158, 11, 1), // Bright amber
    },
    {
      'id': 'trauma',
      'name': 'Trauma',
      'icon': Icons.healing,
      'color': Color.fromRGBO(99, 102, 241, 1), // Bright indigo
    },
  ];

  static const Map<String, String> templates = {
    'daily_tip': '💡 Daily Therapy Tip\n\n[Share your insight here...]',
    'mindfulness':
        '🧘 Mindfulness Exercise\n\nTake a moment to:\n1. \n2. \n3. ',
    'coping_strategy':
        '🛠️ Coping Strategy\n\nWhen you feel [emotion], try:\n\n[Strategy description...]',
    'reflection':
        '🤔 Reflection Prompt\n\nToday, consider:\n\n[Question or prompt...]',
    'progress_update':
        '📈 Progress Update\n\n[Share achievements and growth...]',
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    final state = context.read<TherapyState>();
    state.loadDraft();
    state.startAutoSave();
    state.updateStats();
    state.searchController.addListener(_debounceSearch);
    _initializeStream();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeStream() {
    _postsStream = FirebaseFirestore.instance
        .collection("education")
        .orderBy("createdAt", descending: true)
        .limit(20)
        .snapshots();
  }

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickMedia(
    BuildContext context,
    ImageSource source,
    bool isVideo,
  ) async {
    final state = context.read<TherapyState>();
    if (state.selectedMedia.length >= 1) {
      _showSnackBar(context, "Only one media file is allowed.", Colors.red);
      return;
    }
    try {
      final XFile? pickedFile = isVideo && !kIsWeb
          ? await state.picker.pickVideo(
              source: source,
              maxDuration: const Duration(seconds: 30),
            )
          : await state.picker.pickImage(source: source);

      if (pickedFile != null) {
        List<XFile> updatedMedia = List.from(state.selectedMedia)
          ..add(pickedFile);
        List<Uint8List> updatedWebMediaBytes = List.from(state.webMediaBytes);
        List<VideoPlayerController> updatedControllers = List.from(
          state.videoControllers,
        );

        if (isVideo && !kIsWeb) {
          final file = File(pickedFile.path);
          final controller = VideoPlayerController.file(file);
          await controller.initialize();
          updatedControllers.add(controller);
        } else if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          updatedWebMediaBytes.add(bytes);
        }

        state.updateState(
          newMedia: updatedMedia,
          newWebMediaBytes: updatedWebMediaBytes,
          newVideoControllers: updatedControllers,
        );
      }
    } catch (e) {
      _showSnackBar(context, 'Error picking media: $e', Colors.red);
    }
  }

  Future<void> _uploadPost(BuildContext context) async {
    final state = context.read<TherapyState>();
    if (state.titleController.text.isEmpty ||
        state.contentController.text.trim().isEmpty) {
      _showSnackBar(context, "Title and notes are required", Colors.red);
      return;
    }

    state.updateState(uploading: true);

    try {
      String? mediaUrl;
      if (state.selectedMedia.isNotEmpty) {
        final pickedFile = state.selectedMedia.first;
        final isVideo =
            state.videoControllers.isNotEmpty &&
            state.videoControllers.first.value.isInitialized;
        final extension = isVideo && !kIsWeb ? '.mp4' : '.jpg';

        final ref = FirebaseStorage.instance.ref().child(
          "education/${DateTime.now().millisecondsSinceEpoch}$extension",
        );

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          await ref.putData(
            bytes,
            SettableMetadata(contentType: isVideo ? 'video/mp4' : 'image/jpeg'),
          );
        } else {
          await ref.putFile(File(pickedFile.path));
        }
        mediaUrl = await ref.getDownloadURL();
      }

      final postData = {
        "title": state.titleController.text.trim(),
        "notes": state.contentController.text.trim(),
        "mediaUrl": mediaUrl,
        "category": state.selectedCategory.isNotEmpty
            ? state.selectedCategory
            : null,
        "createdAt": FieldValue.serverTimestamp(),
        "views": 0,
        "likes": 0,
      };

      print('Saving post to Firestore: $postData');

      if (state.editingPostId != null) {
        await FirebaseFirestore.instance
            .collection("education")
            .doc(state.editingPostId)
            .update(postData);
        _showSnackBar(context, "Post updated successfully", primaryGreen);
      } else {
        await FirebaseFirestore.instance.collection("education").add(postData);
        _showSnackBar(context, "Post published successfully", primaryGreen);
      }

      _clearForm(context);
      state.updateState(createPostVisible: false);
      await state.updateStats();
    } catch (e) {
      _showSnackBar(context, "Error uploading post: $e", Colors.red);
    } finally {
      state.updateState(uploading: false);
    }
  }

  void _clearForm(BuildContext context) {
    final state = context.read<TherapyState>();
    state.titleController.clear();
    state.contentController.clear();
    for (var controller in state.videoControllers) {
      controller.dispose();
    }
    state.updateState(
      newMedia: [],
      newWebMediaBytes: [],
      newVideoControllers: [],
      category: '',
      editId: null,
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 253, 255, 254).withOpacity(0.1),
                            const Color.fromARGB(255, 250, 250, 250).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.psychology_rounded,
                                  color: Color.fromARGB(
    255,
    15,
    40,
    20,
  ),// Professional Blue
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                        color: darkText.withOpacity(0.8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.therapistName,
                                      style: const TextStyle(
                                        color: darkText,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 32),
                    Consumer<TherapyState>(
                      builder: (context, state, _) => _buildStatsRow(context),
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<TherapyState>(
                builder: (context, state, _) => state.isCreatePostVisible
                    ? _buildCreatePostCard(context)
                    : _buildPostsSection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final state = context.watch<TherapyState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          'Total Posts',
          state.totalPosts.toString(),
          Icons.article_rounded,
          primaryGreen,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Total Views',
          state.totalViews.toString(),
          Icons.visibility_rounded,
          accentGreen,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Total Likes',
          state.totalLikes.toString(),
          Icons.favorite_rounded,
          lightGreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: darkText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: darkText.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildActionButton(
              'Create Post',
              Icons.add_circle_rounded,
              primaryGreen,
              () {
                context.read<TherapyState>().updateState(
                  createPostVisible: true,
                );
                _clearForm(context);
              },
            ),
            _buildActionButton(
              'Use Template',
              Icons.auto_stories_rounded,
              accentGreen,
              () => _showTemplateModal(context),
            ),
            _buildActionButton(
              'Manage Content',
              Icons.edit_note_rounded,
              lightGreen,
              () {},
            ),
            _buildActionButton(
              'View Reports',
              Icons.analytics_rounded,
              mediumText,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(BuildContext context) {
    return Consumer<TherapyState>(
      builder: (context, state, _) => FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: primaryGreen.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryGreen, accentGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      state.editingPostId != null
                          ? Icons.edit_rounded
                          : Icons.create_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      state.editingPostId != null
                          ? "Edit Post"
                          : "Create New Post",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        state.updateState(createPostVisible: false),
                    icon: Icon(
                      Icons.close_rounded,
                      color: darkText.withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildModernTextField(
                controller: state.titleController,
                label: "Post Title",
                hint: "Enter an engaging title...",
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: 24),
              _buildCategorySelector(context),
              const SizedBox(height: 24),
              _buildModernTextField(
                controller: state.contentController,
                label: "Notes",
                hint: "Share your thoughts and insights...",
                maxLines: 5,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 24),
              if (state.selectedMedia.isNotEmpty) _buildMediaPreview(context),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _pickMedia(context, ImageSource.gallery, false),
                      icon: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 24,
                      ),
                      label: const Text(
                        "Add Image",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(
                          color: primaryGreen.withOpacity(0.4),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: state.isUploading
                          ? null
                          : () => _uploadPost(context),
                      icon: state.isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              state.editingPostId != null
                                  ? Icons.update_rounded
                                  : Icons.publish_rounded,
                              size: 24,
                            ),
                      label: Text(
                        state.isUploading
                            ? "Publishing..."
                            : (state.editingPostId != null
                                  ? "Update Post"
                                  : "Publish Post"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: mediumText, size: 24)
                : null,
            hintStyle: TextStyle(
              color: darkText.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            fillColor: surfaceGreen,
            filled: true,
            alignLabelWithHint: maxLines > 1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primaryGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primaryGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryGreen, width: 2.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<TherapyState>(
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                final isSelected = state.selectedCategory == category['id'];
                return GestureDetector(
                  onTap: () {
                    state.updateState(
                      category: isSelected ? '' : category['id']!,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color']!.withOpacity(0.15)
                          : surfaceGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category['color']!
                            : primaryGreen.withOpacity(0.3),
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: category['color']!.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? category['color'] : mediumText,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name']!,
                          style: TextStyle(
                            color: isSelected ? category['color'] : darkText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context) {
    return Consumer<TherapyState>(
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attached Media',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: surfaceGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryGreen.withOpacity(0.2)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.selectedMedia.length,
              itemBuilder: (context, index) {
                final isVideo =
                    index < state.videoControllers.length &&
                    state.videoControllers[index].value.isInitialized;

                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cardGreen,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.memory(
                                state.webMediaBytes[index],
                                width: 140,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.red.shade400,
                                      size: 40,
                                    ),
                              )
                            : isVideo
                            ? VideoPlayer(state.videoControllers[index])
                            : Image.file(
                                File(state.selectedMedia[index].path),
                                width: 140,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.red.shade400,
                                      size: 40,
                                    ),
                              ),
                      ),
                      if (isVideo && !kIsWeb)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            final updatedMedia = List<XFile>.from(
                              state.selectedMedia,
                            )..removeAt(index);
                            final updatedWebMediaBytes = List<Uint8List>.from(
                              state.webMediaBytes,
                            )..removeAt(index);
                            final updatedControllers =
                                List<VideoPlayerController>.from(
                                  state.videoControllers,
                                );
                            if (isVideo &&
                                index < updatedControllers.length &&
                                !kIsWeb) {
                              updatedControllers[index].dispose();
                              updatedControllers.removeAt(index);
                            }
                            state.updateState(
                              newMedia: updatedMedia,
                              newWebMediaBytes: updatedWebMediaBytes,
                              newVideoControllers: updatedControllers,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardGreen,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, accentGreen],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Post Templates',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...templates.entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: mediumText,
                    size: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: surfaceGreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<TherapyState>().contentController.text =
                        entry.value;
                    context.read<TherapyState>().updateState(
                      createPostVisible: true,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Widget _buildPostsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Posts',
                style: TextStyle(
                  color: darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Consumer<TherapyState>(
                builder: (context, state, _) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryGreen.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: state.sortBy,
                    icon: Icon(Icons.filter_list_rounded, color: mediumText),
                    dropdownColor: cardGreen,
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(
                        value: 'likes',
                        child: Text('Most Liked'),
                      ),
                      DropdownMenuItem(
                        value: 'views',
                        child: Text('Most Viewed'),
                      ),
                    ],
                    onChanged: (value) {
                      state.updateState(sort: value!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: _buildPostsList(context),
        ),
      ],
    );
  }

  Widget _buildPostsList(BuildContext context) {
    final state = context.watch<TherapyState>();
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _postsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade400,
                          size: 64,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Error loading posts',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: darkText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _initializeStream()),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
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
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(state.searchController.text.isNotEmpty);
              }

              var docs = snapshot.data!.docs;
              var filteredDocs = _filterAndSortPosts(docs, state);

              if (filteredDocs.isEmpty) {
                return _buildEmptyState(state.searchController.text.isNotEmpty);
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  var doc = filteredDocs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  return _buildEnhancedPostCard(context, doc.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortPosts(
    List<QueryDocumentSnapshot> docs,
    TherapyState state,
  ) {
    var filteredDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String?)?.toLowerCase() ?? '';
      final content = (data['notes'] as String?)?.toLowerCase() ?? '';
      final category = (data['category'] as String?)?.toLowerCase() ?? '';
      final searchTerm = state.searchController.text.toLowerCase();

      bool matchesSearch =
          searchTerm.isEmpty ||
          title.contains(searchTerm) ||
          content.contains(searchTerm);
      bool matchesCategory =
          state.selectedCategory.isEmpty ||
          category == state.selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    if (state.sortBy == 'views') {
      filteredDocs.sort(
        (a, b) => (b.data() as Map<String, dynamic>)['views'].compareTo(
          (a.data() as Map<String, dynamic>)['views'],
        ),
      );
    } else if (state.sortBy == 'likes') {
      filteredDocs.sort(
        (a, b) => (b.data() as Map<String, dynamic>)['likes'].compareTo(
          (a.data() as Map<String, dynamic>)['likes'],
        ),
      );
    }

    return filteredDocs;
  }

  Widget _buildSearchBar(BuildContext context) {
    final state = context.watch<TherapyState>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        controller: state.searchController,
        style: TextStyle(
          color: darkText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: mediumText, size: 28),
          suffixIcon: state.searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => state.searchController.clear(),
                  icon: Icon(Icons.clear_rounded, color: mediumText, size: 24),
                )
              : null,
          hintText: "Search posts by title...",
          hintStyle: TextStyle(
            color: darkText.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          fillColor: cardGreen,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: primaryGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: primaryGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: primaryGreen, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryGreen.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.inbox_rounded,
                color: primaryGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No results found' : 'No posts yet',
              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different keyword or filter.'
                  : 'Your posts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPostCard(
    BuildContext context,
    String postId,
    Map<String, dynamic> data,
  ) {
    final hasMedia = data['mediaUrl'] != null;
    final categoryData = categories.firstWhere(
      (cat) => cat['id'] == data['category'],
      orElse: () => {
        'name': 'General',
        'icon': Icons.category_rounded,
        'color': mediumText,
      },
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: categoryData['color']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: categoryData['color']!.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        categoryData['icon'],
                        color: categoryData['color'],
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        categoryData['name'],
                        style: TextStyle(
                          color: categoryData['color'],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (data['createdAt'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(data['createdAt'] as Timestamp).toDate().day}/${(data['createdAt'] as Timestamp).toDate().month}/${(data['createdAt'] as Timestamp).toDate().year}',
                      style: TextStyle(
                        color: mediumText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  color: cardGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: mediumText,
                    size: 24,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: primaryGreen),
                          const SizedBox(width: 12),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        final state = context.read<TherapyState>();
                        state.updateState(
                          editId: postId,
                          category: data['category'] ?? '',
                        );
                        state.titleController.text = data['title'] ?? '';
                        state.contentController.text = data['notes'] ?? '';
                        state.updateState(createPostVisible: true);
                      },
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _deletePost(context, postId),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['title'] ?? 'No Title',
              style: TextStyle(
                color: darkText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data['notes'] ?? 'No Content',
              style: TextStyle(
                color: darkText.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: hasMedia ? 4 : null,
              overflow: hasMedia ? TextOverflow.ellipsis : null,
            ),
            if (hasMedia) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.network(
                    data['mediaUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: surfaceGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildStatBadge(
                    Icons.remove_red_eye_rounded,
                    '${data['views'] ?? 0}',
                    'views',
                  ),
                  const SizedBox(width: 24),
                  _buildStatBadge(
                    Icons.favorite_rounded,
                    '${data['likes'] ?? 0}',
                    'likes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: mediumText, size: 20),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: darkText.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete Post',
              style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: darkText.withOpacity(0.8),
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: mediumText,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection("education")
                    .doc(postId)
                    .delete();
                _showSnackBar(
                  context,
                  "Post deleted successfully",
                  primaryGreen,
                );
                context.read<TherapyState>().updateStats();
              } catch (e) {
                _showSnackBar(context, "Error deleting post: $e", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
