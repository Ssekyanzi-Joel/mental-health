import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unnecessary_import
import 'dart:ui';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const Color deepGreen = Color.fromARGB(255, 25, 53, 30);
  static const Color sectionLightGreen = Color.fromARGB(255, 180, 220, 190);
  static const Color listTileCream = Color.fromARGB(255, 245, 245, 220);
  static const Color accentGreen = Color.fromARGB(255, 76, 175, 80);

  @override
  Widget build(BuildContext context) {
    // Try both collections to handle existing and new data
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        title: const Text(
          'Education & Resources',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: deepGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(25, 53, 30, 1),
                const Color.fromRGBO(46, 125, 50, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Read from education collection (from AdminTherapyPage)
        stream: FirebaseFirestore.instance
            .collection('education')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentGreen),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: sectionLightGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: sectionLightGreen.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No educational content yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: sectionLightGreen.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Content will appear here when posted',
                    style: TextStyle(
                      fontSize: 14,
                      color: sectionLightGreen.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildEducationCard(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Untitled';
    final String notes = data['notes'] ?? '';
    final String? mediaUrl = data['mediaUrl'];
    final Timestamp? timestamp = data['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: listTileCream,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: deepGreen.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section (if available)
          if (mediaUrl != null)
            GestureDetector(
              onTap: () => _showFullScreenImage(context, mediaUrl, title),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      mediaUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: sectionLightGreen.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: accentGreen,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: sectionLightGreen.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay for better text readability
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
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
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: deepGreen,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Notes preview
                if (notes.isNotEmpty) ...[
                  Text(
                    notes.length > 150
                        ? '${notes.substring(0, 150)}...'
                        : notes,
                    style: TextStyle(
                      fontSize: 15,
                      color: deepGreen.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),

                  if (notes.length > 150)
                    GestureDetector(
                      onTap: () =>
                          _showFullContent(context, title, notes, mediaUrl),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Read more',
                          style: TextStyle(
                            fontSize: 14,
                            color: accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                // Footer with timestamp and read more button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timestamp
                    if (timestamp != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sectionLightGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: deepGreen.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(timestamp.toDate()),
                              style: TextStyle(
                                fontSize: 12,
                                color: deepGreen.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Read more button
                    if (notes.isNotEmpty)
                      GestureDetector(
                        onTap: () =>
                            _showFullContent(context, title, notes, mediaUrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'View Full',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(imageUrl: imageUrl, title: title),
      ),
    );
  }

  void _showFullContent(
    BuildContext context,
    String title,
    String notes,
    String? mediaUrl,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullContentView(title: title, content: notes, imageUrl: mediaUrl),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Full screen image viewer
class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Full content viewer
class FullContentView extends StatelessWidget {
  final String title;
  final String content;
  final String? imageUrl;

  const FullContentView({
    super.key,
    required this.title,
    required this.content,
    this.imageUrl,
  });

  static const Color deepGreen = Color.fromARGB(255, 25, 53, 30);
  static const Color sectionLightGreen = Color.fromARGB(255, 180, 220, 190);
  static const Color listTileCream = Color.fromARGB(255, 245, 245, 220);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageUrl != null ? 300 : 120,
            floating: false,
            pinned: true,
            backgroundColor: deepGreen,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(imageUrl!, fit: BoxFit.cover),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromRGBO(25, 53, 30, 1),
                            const Color.fromRGBO(46, 125, 50, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: listTileCream,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: deepGreen.withOpacity(0.15),
                    blurRadius: 10,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: deepGreen,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: deepGreen.withOpacity(0.8),
                      height: 1.6,
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
