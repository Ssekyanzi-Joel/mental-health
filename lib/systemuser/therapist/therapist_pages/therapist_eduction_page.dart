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
  List<XFile> selectedMedia = []; // Changed to XFile for web compatibility
  List<Uint8List> webMediaBytes = []; // Store bytes for web image previews
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
  static const Color primaryGreen = Color.fromRGBO(25, 53, 30, 1);
  static const Color accentGreen = Color.fromRGBO(46, 125, 50, 1);
  static const Color lightGreen = Color.fromRGBO(76, 175, 80, 1);
  static const Color paleGreen = Color.fromRGBO(129, 199, 132, 1);
  static const Color backgroundGreen = Color.fromRGBO(15, 40, 20, 1);
  static const Color cardGreen = Color.fromRGBO(35, 70, 40, 1);

  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'anxiety',
      'name': 'Anxiety',
      'icon': Icons.psychology,
      'color': Colors.orange,
    },
    {
      'id': 'depression',
      'name': 'Depression',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.blue,
    },
    {
      'id': 'mindfulness',
      'name': 'Mindfulness',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
    },
    {
      'id': 'stress',
      'name': 'Stress',
      'icon': Icons.flash_on,
      'color': Colors.red,
    },
    {
      'id': 'relationships',
      'name': 'Relationships',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
    {
      'id': 'self_care',
      'name': 'Self Care',
      'icon': Icons.spa,
      'color': Colors.teal,
    },
    {
      'id': 'coping',
      'name': 'Coping Skills',
      'icon': Icons.emoji_objects,
      'color': Colors.amber,
    },
    {
      'id': 'trauma',
      'name': 'Trauma',
      'icon': Icons.healing,
      'color': Colors.indigo,
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

      print('Saving post to Firestore: $postData'); // Debug log

      if (state.editingPostId != null) {
        await FirebaseFirestore.instance
            .collection("education")
            .doc(state.editingPostId)
            .update(postData);
        _showSnackBar(context, "Post updated successfully", lightGreen);
      } else {
        await FirebaseFirestore.instance.collection("education").add(postData);
        _showSnackBar(context, "Post published successfully", lightGreen);
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
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: paleGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.therapistName,
                      style: const TextStyle(
                        color: lightGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<TherapyState>(
                      builder: (context, state, _) => _buildStatsRow(context),
                    ),
                    const SizedBox(height: 24),
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
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Total Views',
          state.totalViews.toString(),
          Icons.visibility_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Total Likes',
          state.totalLikes.toString(),
          Icons.favorite_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentGreen.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: lightGreen, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: paleGreen,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton('Create Post', Icons.add_circle, () {
          context.read<TherapyState>().updateState(createPostVisible: true);
          _clearForm(context);
        }),
        _buildActionButton('Use Template', Icons.auto_stories, () {
          _showTemplateModal(context);
        }),
        _buildActionButton('Manage Content', Icons.edit_note, () {}),
        _buildActionButton('View Reports', Icons.analytics, () {}),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentGreen.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: lightGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: paleGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(BuildContext context) {
    return Consumer<TherapyState>(
      builder: (context, state, _) => FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardGreen, accentGreen.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      state.editingPostId != null ? Icons.edit : Icons.create,
                      color: paleGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    state.editingPostId != null
                        ? "Edit Post"
                        : "Create New Post",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: paleGreen,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        state.updateState(createPostVisible: false),
                    icon: const Icon(Icons.close, color: paleGreen),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                controller: state.titleController,
                label: "Post Title",
                hint: "Enter an engaging title...",
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 20),
              _buildCategorySelector(context),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: state.contentController,
                label: "Notes",
                hint: "Share your thoughts and insights...",
                maxLines: 4,
                prefixIcon: Icons.notes,
              ),
              const SizedBox(height: 20),
              if (state.selectedMedia.isNotEmpty) _buildMediaPreview(context),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _pickMedia(context, ImageSource.gallery, false),
                      icon: const Icon(Icons.add_photo_alternate, size: 20),
                      label: const Text("Add Image"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: paleGreen,
                        side: BorderSide(color: paleGreen.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: state.isUploading
                          ? null
                          : () => _uploadPost(context),
                      icon: state.isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              state.editingPostId != null
                                  ? Icons.update
                                  : Icons.publish,
                              size: 20,
                            ),
                      label: Text(
                        state.isUploading
                            ? "Publishing..."
                            : (state.editingPostId != null
                                  ? "Update Post"
                                  : "Publish Post"),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: paleGreen)
            : null,
        labelStyle: const TextStyle(
          color: paleGreen,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        fillColor: primaryGreen,
        filled: true,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<TherapyState>(
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              color: paleGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
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
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color']!.withOpacity(0.3)
                          : primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? category['color']!
                            : accentGreen.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? category['color'] : paleGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name']!,
                          style: TextStyle(
                            color: isSelected ? category['color'] : paleGreen,
                            fontWeight: FontWeight.w600,
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
          const Text(
            'Attached Media',
            style: TextStyle(
              color: paleGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.selectedMedia.length,
              itemBuilder: (context, index) {
                final isVideo =
                    index < state.videoControllers.length &&
                    state.videoControllers[index].value.isInitialized;

                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: primaryGreen,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.memory(
                                state.webMediaBytes[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                              )
                            : isVideo
                            ? VideoPlayer(state.videoControllers[index])
                            : Image.file(
                                File(state.selectedMedia[index].path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                              ),
                      ),
                      if (isVideo && !kIsWeb)
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      if (kIsWeb)
                        const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
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
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
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
        ],
      ),
    );
  }

  void _showTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Post Templates',
              style: TextStyle(
                color: paleGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...templates.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.description, color: lightGreen),
                title: Text(
                  entry.key.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: paleGreen),
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Posts',
                style: TextStyle(
                  color: paleGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<TherapyState>(
                builder: (context, state, _) => DropdownButton<String>(
                  value: state.sortBy,
                  icon: const Icon(Icons.filter_list, color: lightGreen),
                  dropdownColor: cardGreen,
                  style: const TextStyle(color: paleGreen),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'likes', child: Text('Most Liked')),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                return const Center(
                  child: CircularProgressIndicator(color: lightGreen),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading posts: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => setState(() => _initializeStream()),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: lightGreen, fontSize: 16),
                        ),
                      ),
                    ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: state.searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: paleGreen),
          suffixIcon: state.searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => state.searchController.clear(),
                  icon: const Icon(Icons.clear, color: paleGreen),
                )
              : null,
          hintText: "Search posts by title...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          fillColor: cardGreen,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentGreen.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: lightGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inbox_rounded,
            color: paleGreen,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No results found' : 'No posts yet',
            style: const TextStyle(
              color: paleGreen,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different keyword or filter.'
                : 'Your posts will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
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
        'icon': Icons.category,
        'color': Colors.grey,
      },
    );

    return Card(
      color: cardGreen,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentGreen.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryData['icon'], color: categoryData['color']),
                const SizedBox(width: 8),
                Text(
                  categoryData['name'],
                  style: TextStyle(
                    color: categoryData['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (data['createdAt'] != null)
                  Text(
                    '${(data['createdAt'] as Timestamp).toDate().day}/${(data['createdAt'] as Timestamp).toDate().month}/${(data['createdAt'] as Timestamp).toDate().year}',
                    style: TextStyle(
                      color: paleGreen.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                PopupMenuButton(
                  color: cardGreen,
                  icon: const Icon(Icons.more_vert, color: paleGreen),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: lightGreen),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: paleGreen)),
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
                        children: const [
                          Icon(Icons.delete, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: paleGreen)),
                        ],
                      ),
                      onTap: () => _deletePost(context, postId),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['title'] ?? 'No Title',
              style: const TextStyle(
                color: paleGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['notes'] ?? 'No Content',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: hasMedia ? 3 : null,
              overflow: hasMedia ? TextOverflow.ellipsis : null,
            ),
            if (hasMedia) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data['mediaUrl'],
                  fit: BoxFit.cover,
                  width: 280,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  color: paleGreen.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['views'] ?? 0}',
                  style: TextStyle(
                    color: paleGreen.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.favorite_outline,
                  color: paleGreen.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['likes'] ?? 0}',
                  style: TextStyle(
                    color: paleGreen.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardGreen,
        title: const Text('Delete Post', style: TextStyle(color: paleGreen)),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: paleGreen)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection("education")
                    .doc(postId)
                    .delete();
                _showSnackBar(context, "Post deleted successfully", lightGreen);
                context.read<TherapyState>().updateStats();
              } catch (e) {
                _showSnackBar(context, "Error deleting post: $e", Colors.red);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
