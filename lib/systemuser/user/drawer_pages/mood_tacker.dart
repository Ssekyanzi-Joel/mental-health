import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnhancedMoodTrackerPage extends StatefulWidget {
  const EnhancedMoodTrackerPage({super.key});

  @override
  State<EnhancedMoodTrackerPage> createState() =>
      _EnhancedMoodTrackerPageState();
}

class _EnhancedMoodTrackerPageState extends State<EnhancedMoodTrackerPage>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  // Test mode flag - set to true to test UI without Firestore
  static const bool _testMode = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Enhanced color palette with mood-based gradients
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);

  static const Color creamWhite = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;

  // Mood colors for better visual distinction
  static const Map<int, Color> moodColors = {
    1: Color(0xFF8E24AA), // Deep Purple - Very sad
    2: Color(0xFF5E35B1), // Purple - Sad
    3: Color(0xFF3949AB), // Indigo - Low
    4: Color(0xFF1E88E5), // Blue - Below average
    5: Color(0xFF00ACC1), // Cyan - Neutral
    6: Color(0xFF00897B), // Teal - Okay
    7: Color(0xFF43A047), // Green - Good
    8: Color(0xFF7CB342), // Light green - Very good
    9: Color(0xFFFDD835), // Yellow - Happy
    10: Color(0xFFFF9800), // Orange - Ecstatic
  };

  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😭', 'label': 'Terrible', 'score': 1},
    {'emoji': '😢', 'label': 'Very Sad', 'score': 2},
    {'emoji': '😟', 'label': 'Sad', 'score': 3},
    {'emoji': '😐', 'label': 'Poor', 'score': 4},
    {'emoji': '🙂', 'label': 'Neutral', 'score': 5},
    {'emoji': '😊', 'label': 'Okay', 'score': 6},
    {'emoji': '😄', 'label': 'Good', 'score': 7},
    {'emoji': '😃', 'label': 'Great', 'score': 8},
    {'emoji': '😁', 'label': 'Amazing', 'score': 9},
    {'emoji': '🤩', 'label': 'Fantastic', 'score': 10},
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _slideController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskToday());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _maybeAskToday() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final q = await _fire
        .collection('mood_tracker')
        .where('userId', isEqualTo: user.uid)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showEnhancedMoodDialog();
      });
    }
  }

  Future<void> _showEnhancedMoodDialog() async {
    final user = _auth.currentUser;
    if (user == null) return;

    int selectedScore = 5;
    String selectedEmoji = '🙂';
    String selectedLabel = 'Neutral';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      moodColors[selectedScore]!.withOpacity(0.1),
                      cardWhite,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with animated emoji
                    AnimatedScale(
                      scale: selectedScore > 7 ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: moodColors[selectedScore]!.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            selectedEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: moodColors[selectedScore]!.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: moodColors[selectedScore],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mood selection grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: _moodOptions.length,
                      itemBuilder: (context, index) {
                        final mood = _moodOptions[index];
                        final isSelected = mood['score'] == selectedScore;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedScore = mood['score'];
                              selectedEmoji = mood['emoji'];
                              selectedLabel = mood['label'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? moodColors[mood['score']]!.withOpacity(0.2)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? moodColors[mood['score']]!
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                mood['emoji'],
                                style: TextStyle(
                                  fontSize: isSelected ? 28 : 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final today = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now());
                              try {
                                await _fire.collection('mood_tracker').add({
                                  'userId': user.uid,
                                  'date': today,
                                  'score': selectedScore,
                                  'emoji': selectedEmoji,
                                  'label': selectedLabel,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                                if (mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Text(selectedEmoji),
                                          const SizedBox(width: 8),
                                          Text('Mood saved: $selectedLabel'),
                                        ],
                                      ),
                                      backgroundColor: accentGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save mood: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: moodColors[selectedScore],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Mood',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _moodStream() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('MoodTracker: No authenticated user');
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    debugPrint('MoodTracker: Loading mood data for user: ${user.uid}');

    // Try simple query first (without orderBy to avoid index issues)
    return _fire
        .collection('mood_tracker')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: (sink) {
            debugPrint('MoodTracker: Query timeout - likely permissions issue');
            sink.addError(
              'Connection timeout. Please check your internet connection and try again.',
            );
          },
        )
        .handleError((error) {
          debugPrint('MoodTracker Stream Error: $error');
        });
  }

  Widget _buildMoodSummaryCard(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return Card(
        elevation: 0,
        color: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentGreen.withOpacity(0.1), cardWhite],
            ),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎯', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Start Your Journey',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your daily mood to understand patterns and improve your well-being',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _showEnhancedMoodDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Log Your First Mood',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate mood statistics
    final recent7Days = docs.take(7).toList();
    final scores = recent7Days
        .map<int>(
          (d) => ((d.data() as Map<String, dynamic>)['score'] as int?) ?? 5,
        )
        .toList();

    final avgMood = scores.isNotEmpty
        ? scores.reduce((a, b) => a + b) / scores.length
        : 5.0;

    final latestMood = docs.first.data() as Map<String, dynamic>?;
    final latestEmoji = latestMood?['emoji'] as String? ?? '🙂';
    final latestScore = latestMood?['score'] as int? ?? 5;
    final latestLabel = latestMood?['label'] as String? ?? 'Neutral';

    return Card(
      elevation: 0,
      color: cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [moodColors[latestScore]!.withOpacity(0.1), cardWhite],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: moodColors[latestScore]!.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      latestEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Mood',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        latestLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: moodColors[latestScore],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showEnhancedMoodDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Weekly average
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: accentGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '7-day average: ${avgMood.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${docs.length} entries',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: creamWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Please sign in to track your mood',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _testMode
          ? _buildTestUI()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _moodStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('MoodTracker UI Error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading mood data',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild to retry
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: accentGreen),
                        SizedBox(height: 16),
                        Text('Loading mood data...'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  debugPrint('MoodTracker: No data received from Firestore');
                  return const Center(
                    child: CircularProgressIndicator(color: accentGreen),
                  );
                }

                final docs = snapshot.data!.docs;

                // Sort docs by timestamp on client side (since we removed orderBy)
                docs.sort((a, b) {
                  final aTime =
                      (a.data()['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  final bTime =
                      (b.data()['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  return bTime.compareTo(
                    aTime,
                  ); // Descending order (newest first)
                });

                return SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    color: accentGreen,
                    onRefresh: () async {
                      // Trigger a refresh by re-querying
                      await _fire
                          .collection('mood_tracker')
                          .where('userId', isEqualTo: user.uid)
                          .get();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary card
                          _buildMoodSummaryCard(docs),

                          if (docs.isNotEmpty) ...[
                            const SizedBox(height: 24),

                            // Chart section would go here
                            // You can add your existing chart widgets here
                            const SizedBox(height: 24),

                            // Recent entries
                            Row(
                              children: [
                                const Text(
                                  'Recent Entries',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Last 10',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Mood entries list
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.take(10).length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data();
                                final score = (data['score'] as int?) ?? 5;
                                final emoji =
                                    (data['emoji'] as String?) ?? '🙂';
                                final label =
                                    (data['label'] as String?) ?? 'Neutral';
                                final timestamp =
                                    (data['timestamp'] as Timestamp?);

                                final timeDisplay = timestamp != null
                                    ? DateFormat.MMMd().add_jm().format(
                                        timestamp.toDate(),
                                      )
                                    : 'Unknown time';

                                return Card(
                                  elevation: 0,
                                  color: cardWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: moodColors[score]!.withOpacity(
                                        0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: moodColors[score]!.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: moodColors[score],
                                        fontSize: 12,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          timeDisplay,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: moodColors[score]!
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Score: $score/10',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: moodColors[score],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          await _fire
                                              .collection('mood_tracker')
                                              .doc(doc.id)
                                              .delete();
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Test UI to verify the layout works without Firestore
  Widget _buildTestUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test summary card with empty data
          _buildMoodSummaryCard([]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Test Mode Active',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UI is working. The issue is with Firestore connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange.shade700),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test mode - no data will be saved'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Button'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
