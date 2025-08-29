import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleMoodTrackerPage extends StatefulWidget {
  const SimpleMoodTrackerPage({super.key});

  @override
  State<SimpleMoodTrackerPage> createState() => _SimpleMoodTrackerPageState();
}

class _SimpleMoodTrackerPageState extends State<SimpleMoodTrackerPage> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color creamWhite = Color(0xFFF8F9FA);

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

  Future<void> _saveMood(int score, String emoji, String label) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _fire.collection('mood_tracker').add({
        'userId': user.uid,
        'date': today,
        'score': score,
        'emoji': emoji,
        'label': label,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood saved: $label $emoji'),
            backgroundColor: accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: creamWhite,
        appBar: AppBar(
          title: const Text('Mood Tracker'),
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Please sign in to track your mood',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamWhite,
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _moodOptions.length,
                itemBuilder: (context, index) {
                  final mood = _moodOptions[index];
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _saveMood(
                        mood['score'],
                        mood['emoji'],
                        mood['label'],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mood['emoji'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood['label'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${mood['score']}/10',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Simple mood history
            StreamBuilder<QuerySnapshot>(
              stream: _fire
                  .collection('mood_tracker')
                  .where('userId', isEqualTo: user.uid)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text(
                    'No mood entries yet. Tap a mood above to get started!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Moods:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              data['emoji'] ?? '🙂',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              data['label'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              data['date'] ?? 'Unknown date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
