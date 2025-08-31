import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  // Modern minimalist color scheme
  static const Color primaryBackground = Color(0xFFFAFBFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1A1D29);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color accent = Color(0xFF10B981);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color gradientStart = Color(0xFF059669);
  static const Color gradientEnd = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Clean modern header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and title
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: primaryText,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Education Hub",
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Discover knowledge and insights",
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.article_outlined,
                            title: "Articles",
                            subtitle: "Latest content",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_up,
                            title: "Learning",
                            subtitle: "Keep growing",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content section
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('education')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(50),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: accent,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading content...",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 32,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No content available yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Educational content will appear here when published',
                          style: TextStyle(fontSize: 12, color: secondaryText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildEducationCard(context, data);
                  }, childCount: docs.length),
                ),
              );
            },
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          Text(subtitle, style: TextStyle(fontSize: 10, color: secondaryText)),
        ],
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Untitled';
    final String notes = data['notes'] ?? '';
    final String? mediaUrl = data['mediaUrl'];
    final String? mediaPath =
        data['mediaPath']; // Alternative: direct storage path
    final Timestamp? timestamp = data['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart Image section with multiple fallback strategies
          if (mediaUrl != null || mediaPath != null)
            GestureDetector(
              onTap: () => _showFullScreenImage(
                context,
                mediaUrl ?? mediaPath!,
                title,
                isStoragePath: mediaPath != null && mediaUrl == null,
              ),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SmartImageWidget(
                        mediaUrl: mediaUrl,
                        mediaPath: mediaPath,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    // Overlay with expand icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('MMM dd').format(timestamp.toDate()),
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Content preview
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    notes.length > 120
                        ? '${notes.substring(0, 120)}...'
                        : notes,
                    style: TextStyle(
                      fontSize: 15,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      if (notes.length > 120)
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gradientStart, gradientEnd],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showFullContent(
                                  context,
                                  title,
                                  notes,
                                  mediaUrl,
                                  mediaPath,
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.article_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Read More",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if ((mediaUrl != null || mediaPath != null) &&
                          notes.length > 120)
                        const SizedBox(width: 12),
                      if (mediaUrl != null || mediaPath != null)
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: lightGray,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showFullScreenImage(
                                  context,
                                  mediaUrl ?? mediaPath!,
                                  title,
                                  isStoragePath:
                                      mediaPath != null && mediaUrl == null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: primaryText,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "View Image",
                                        style: TextStyle(
                                          color: primaryText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imagePath,
    String title, {
    bool isStoragePath = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(
          imagePath: imagePath,
          title: title,
          isStoragePath: isStoragePath,
        ),
      ),
    );
  }

  void _showFullContent(
    BuildContext context,
    String title,
    String notes,
    String? mediaUrl,
    String? mediaPath,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullContentView(
          title: title,
          content: notes,
          mediaUrl: mediaUrl,
          mediaPath: mediaPath,
        ),
      ),
    );
  }
}

// Smart Image Widget with Multiple Fallback Strategies
class SmartImageWidget extends StatefulWidget {
  final String? mediaUrl;
  final String? mediaPath;
  final double width;
  final double height;
  final BoxFit fit;

  const SmartImageWidget({
    super.key,
    this.mediaUrl,
    this.mediaPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<SmartImageWidget> createState() => _SmartImageWidgetState();
}

class _SmartImageWidgetState extends State<SmartImageWidget> {
  String? _currentUrl;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isLoading = true;
  String? _errorMessage;

  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color accent = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (_retryCount >= _maxRetries) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load image after $_maxRetries attempts';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String? urlToTry;

      if (_retryCount == 0 && widget.mediaUrl != null) {
        // First attempt: Use the provided mediaUrl as-is
        urlToTry = widget.mediaUrl!;
      } else if (_retryCount == 1 && widget.mediaUrl != null) {
        // Second attempt: Try domain replacement
        urlToTry = widget.mediaUrl!
            .replaceAll('firebasestorage.app', 'appspot.com')
            .replaceAll(
              'mind-aware-b89c3.firebasestorage.app',
              'mind-aware-b89c3.appspot.com',
            );
      } else if (widget.mediaPath != null) {
        // Third attempt: Generate URL from storage path
        try {
          final ref = FirebaseStorage.instance.ref().child(widget.mediaPath!);
          urlToTry = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Failed to get download URL from path: $e');
          _retryCount++;
          await Future.delayed(Duration(milliseconds: 500 * _retryCount));
          _loadImage();
          return;
        }
      } else {
        // No more options
        setState(() {
          _isLoading = false;
          _errorMessage = 'No valid image source available';
        });
        return;
      }

      if (urlToTry != null) {
        setState(() {
          _currentUrl = urlToTry;
        });
      } else {
        _retryCount++;
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));
        _loadImage();
      }
    } catch (e) {
      debugPrint('Error in _loadImage: $e');
      _retryCount++;
      await Future.delayed(Duration(milliseconds: 500 * _retryCount));
      _loadImage();
    }
  }

  void _onImageError() {
    debugPrint('Image failed to load: $_currentUrl');
    _retryCount++;
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        _loadImage();
      }
    });
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: lightGray),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 48, color: secondaryText),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Image failed to load',
            style: TextStyle(color: secondaryText, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_retryCount < _maxRetries)
            GestureDetector(
              onTap: () {
                _retryCount = 0;
                _loadImage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: lightGray),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(color: accent, strokeWidth: 3),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading image... (${_retryCount + 1}/$_maxRetries)',
              style: TextStyle(color: secondaryText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUrl == null) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return Image.network(
      _currentUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          setState(() => _isLoading = false);
          return child;
        }
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Network image error: $error for URL: $_currentUrl');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onImageError();
          }
        });
        return _buildLoadingWidget();
      },
    );
  }
}

// Enhanced Full screen image viewer
class FullScreenImageView extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isStoragePath;

  const FullScreenImageView({
    super.key,
    required this.imagePath,
    required this.title,
    this.isStoragePath = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const BackButton(color: Colors.white),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: SmartImageWidget(
            mediaUrl: isStoragePath ? null : imagePath,
            mediaPath: isStoragePath ? imagePath : null,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// Enhanced Full content viewer
class FullContentView extends StatelessWidget {
  final String title;
  final String content;
  final String? mediaUrl;
  final String? mediaPath;

  const FullContentView({
    super.key,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.mediaPath,
  });

  static const Color primaryBackground = Color(0xFFFAFBFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1A1D29);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = mediaUrl != null || mediaPath != null;

    return Scaffold(
      backgroundColor: primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 280 : 120,
            floating: false,
            pinned: true,
            backgroundColor: cardBackground,
            foregroundColor: primaryText,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 60,
                bottom: 16,
                right: 16,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        SmartImageWidget(
                          mediaUrl: mediaUrl,
                          mediaPath: mediaPath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: cardBackground,
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryText,
                        height: 1.6,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
