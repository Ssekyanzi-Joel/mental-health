import 'package:flutter/material.dart';

class ArticlesPage extends StatelessWidget {
  ArticlesPage({super.key});

  final List<Map<String, String>> articles = [
    {
      'title': 'Managing Stress Effectively',
      'description':
          'Learn practical techniques to manage stress and improve your mental well-being.',
      'image': 'assets/images/article1.png',
      'content': 'Full content for Managing Stress Effectively...',
      'readTime': '5 min read',
      'category': 'Stress Management',
    },
    {
      'title': 'Understanding Anxiety',
      'description':
          'An in-depth guide to understanding anxiety and how to cope with it.',
      'image': 'assets/images/article2.png',
      'content': 'Full content for Understanding Anxiety...',
      'readTime': '7 min read',
      'category': 'Mental Health',
    },
    {
      'title': 'The Power of Meditation',
      'description':
          'Discover how meditation can positively affect your mental health.',
      'image': 'assets/images/article3.png',
      'content': 'Full content for The Power of Meditation...',
      'readTime': '4 min read',
      'category': 'Mindfulness',
    },
    {
      'title': 'Healthy Sleep Habits',
      'description': 'Tips to improve your sleep and boost mental clarity.',
      'image': 'assets/images/article4.png',
      'content': 'Full content for Healthy Sleep Habits...',
      'readTime': '6 min read',
      'category': 'Wellness',
    },
    {
      'title': 'Building Emotional Resilience',
      'description':
          'Learn how to become more resilient to life\'s challenges.',
      'image': 'assets/images/article5.png',
      'content': 'Full content for Building Emotional Resilience...',
      'readTime': '8 min read',
      'category': 'Resilience',
    },
    {
      'title': 'Coping with Depression',
      'description':
          'Practical advice and strategies for coping with depression.',
      'image': 'assets/images/article6.png',
      'content': 'Full content for Coping with Depression...',
      'readTime': '9 min read',
      'category': 'Mental Health',
    },
    {
      'title': 'Mindful Eating',
      'description':
          'How mindful eating can improve mental and physical health.',
      'image': 'assets/images/article7.png',
      'content': 'Full content for Mindful Eating...',
      'readTime': '5 min read',
      'category': 'Mindfulness',
    },
    {
      'title': 'Boosting Self-Esteem',
      'description': 'Steps to build self-confidence and self-worth.',
      'image': 'assets/images/article8.png',
      'content': 'Full content for Boosting Self-Esteem...',
      'readTime': '6 min read',
      'category': 'Self-Care',
    },
    {
      'title': 'Managing Anger',
      'description': 'Learn techniques to manage anger effectively.',
      'image': 'assets/images/article9.png',
      'content': 'Full content for Managing Anger...',
      'readTime': '4 min read',
      'category': 'Emotional Control',
    },
    {
      'title': 'Gratitude Practices',
      'description':
          'Simple ways to practice gratitude daily for a happier mind.',
      'image': 'assets/images/article10.png',
      'content': 'Full content for Gratitude Practices...',
      'readTime': '3 min read',
      'category': 'Positivity',
    },
  ];

  // Brand colors
  static const Color primaryGreen = Color.fromRGBO(25, 53, 30, 1);
  static const Color accentGreen = Color.fromRGBO(46, 125, 50, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: primaryGreen,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Wellness Articles',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryGreen, accentGreen],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.2,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final article = articles[index];
                return _buildModernArticleCard(context, article);
              }, childCount: articles.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernArticleCard(
    BuildContext context,
    Map<String, String> article,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(article['image']!, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article['category']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article['readTime']!,
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: primaryGreen,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        article['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailPage(
                                title: article['title']!,
                                content: article['content']!,
                                image: article['image']!,
                                category: article['category']!,
                                readTime: article['readTime']!,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Read Article',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String image;
  final String category;
  final String readTime;

  // Brand colors
  static const Color primaryGreen = Color.fromRGBO(25, 53, 30, 1);
  static const Color accentGreen = Color.fromRGBO(46, 125, 50, 1);

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.image,
    required this.category,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryGreen,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: Icon(Icons.share, color: primaryGreen, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          primaryGreen.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: accentGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              readTime,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Bookmark functionality
                            },
                            icon: const Icon(Icons.bookmark_border, size: 18),
                            label: const Text('Save Article'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: primaryGreen,
                              elevation: 0,
                              side: BorderSide(color: primaryGreen, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Share functionality
                            },
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
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
          ),
        ],
      ),
    );
  }
}
