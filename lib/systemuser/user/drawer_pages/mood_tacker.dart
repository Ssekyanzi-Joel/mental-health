import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  // Your green theme colors
  static const Color mainThemeColor = Color.fromRGBO(25, 53, 30, 1);
  static const Color cardContainer = Color.fromRGBO(35, 70, 40, 1);
  static const Color accentGreen = Color.fromRGBO(76, 175, 80, 1);
  static const Color lightGreen = Color.fromRGBO(129, 199, 132, 1);
  static const Color creamWhite = Color(0xFFF7F5F3);
  static const Color lightCream = Color(0xFFE8F5E8);

  final List<String> _emojiOptions = [
    '😭',
    '😟',
    '🤔',
    '😐',
    '🙂',
    '😊',
    '😄',
    '😃',
    '😁',
    '🤩',
  ];

  @override
  void initState() {
    super.initState();
    print("=== MoodTracker Debug ===");
    print("Current user: ${_auth.currentUser?.uid}");
    print("User email: ${_auth.currentUser?.email}");
    print("========================");
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskToday());
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
      _showMoodDialog();
    }
  }

  Future<void> _showMoodDialog() async {
    final user = _auth.currentUser;
    if (user == null) return;

    int sliderValue = 5;
    String? chosenEmoji;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('How are you feeling today?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tap an emoji or use the slider (1 = very sad, 10 = very happy)',
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _emojiOptions.map((e) {
                        final selected = chosenEmoji == e;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            avatar: selected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                            label: Text(
                              e,
                              style: const TextStyle(fontSize: 20),
                            ),
                            selectedColor: accentGreen,
                            selected: selected,
                            onSelected: (_) => setStateSB(() {
                              chosenEmoji = e;
                              sliderValue = _emojiToScore(e);
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('1'),
                      Expanded(
                        child: Slider(
                          value: sliderValue.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: sliderValue.toString(),
                          activeColor: accentGreen,
                          onChanged: (v) {
                            setStateSB(() {
                              sliderValue = v.round();
                              chosenEmoji = _scoreToEmoji(sliderValue);
                            });
                          },
                        ),
                      ),
                      const Text('10'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chosenEmoji != null
                        ? 'Selected: $chosenEmoji  •  Score: $sliderValue'
                        : 'Score: $sliderValue',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final today = DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime.now());
                    try {
                      await _fire.collection('mood_tracker').add({
                        'userId': user.uid,
                        'date': today,
                        'score': sliderValue,
                        'emoji': chosenEmoji ?? _scoreToEmoji(sliderValue),
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save mood: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _emojiToScore(String emoji) {
    final idx = _emojiOptions.indexOf(emoji);
    if (idx < 0) return 5;
    return idx + 1;
  }

  String _scoreToEmoji(int score) {
    final index = (score - 1).clamp(0, 9);
    return _emojiOptions[index];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _moodStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return _fire
        .collection('mood_tracker')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  List<BarChartGroupData> _buildBarGroups(List<int> scores) {
    return List.generate(scores.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: scores[i].toDouble(),
            width: 12,
            borderRadius: BorderRadius.circular(4),
            color: accentGreen,
          ),
        ],
      );
    });
  }

  List<FlSpot> _buildSpots(List<int> scores) {
    return List.generate(
      scores.length,
      (i) => FlSpot(i.toDouble(), scores[i].toDouble()),
    );
  }

  List<int> _histogramCounts(List<int> scores) {
    final counts = List<int>.filled(10, 0);
    for (final s in scores) {
      if (s >= 1 && s <= 10) counts[s - 1] += 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    print("Build called - user: ${user?.uid}");

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mood Tracker'),
          backgroundColor: mainThemeColor,
          foregroundColor: Colors.white,
        ),
        backgroundColor: creamWhite,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Please sign in to use mood tracker',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: mainThemeColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: creamWhite,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _moodStream(),
        builder: (context, snapshot) {
          print("StreamBuilder state: ${snapshot.connectionState}");
          if (snapshot.hasError) {
            print("StreamBuilder error: ${snapshot.error}");
          }
          if (snapshot.hasData) {
            print(
              "StreamBuilder data: ${snapshot.data!.docs.length} documents",
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading mood data: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: accentGreen),
            );
          }

          final docs = snapshot.data!.docs;

          docs.sort((a, b) {
            final aTimestamp = a.data()['timestamp'] as Timestamp?;
            final bTimestamp = b.data()['timestamp'] as Timestamp?;

            if (aTimestamp == null && bTimestamp == null) return 0;
            if (aTimestamp == null) return 1;
            if (bTimestamp == null) return -1;

            return bTimestamp.compareTo(aTimestamp);
          });

          final recent = docs.take(30).toList();
          final chartList = recent.reversed.toList();
          final scores = chartList
              .map<int>((d) => (d.data()['score'] as int? ?? 0))
              .toList();
          final labels = chartList
              .map<String>((d) => (d.data()['date'] as String? ?? ''))
              .toList();

          final histogramCounts = _histogramCounts(scores);

          return RefreshIndicator(
            color: accentGreen,
            onRefresh: () async {
              await _fire
                  .collection('mood_tracker')
                  .where('userId', isEqualTo: user.uid)
                  .get();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick summary card
                  Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.show_chart, size: 36, color: accentGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Mood',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: mainThemeColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Answer once per day. Latest entries shown below.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showMoodDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add today'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bar Chart
                  Text(
                    'Bar chart (recent days)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: mainThemeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: scores.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 10.5,
                              minY: 0,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (v, meta) {
                                      final idx = v.toInt();
                                      if (idx < 0 || idx >= labels.length) {
                                        return const Text('');
                                      }
                                      final label = labels[idx];
                                      try {
                                        final dt = DateFormat(
                                          'yyyy-MM-dd',
                                        ).parse(label);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            DateFormat.Md().format(dt),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      } catch (_) {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              barGroups: _buildBarGroups(scores),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Line Chart
                  Text(
                    'Line chart (trend)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: mainThemeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: scores.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 10,
                              titlesData: FlTitlesData(
                                show: true,
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildSpots(scores),
                                  isCurved: true,
                                  dotData: FlDotData(show: true),
                                  color: cardContainer,
                                  barWidth: 3,
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Histogram
                  Text(
                    'Histogram (frequency)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: mainThemeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: histogramCounts.every((c) => c == 0)
                        ? const Center(child: Text('No data yet'))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  (histogramCounts.reduce(
                                            (a, b) => a > b ? a : b,
                                          ) +
                                          1)
                                      .toDouble(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (v, meta) {
                                      final idx = v.toInt();
                                      if (idx < 1 || idx > 10) {
                                        return const SizedBox();
                                      }
                                      return Text(idx.toString());
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              barGroups: List.generate(10, (i) {
                                return BarChartGroupData(
                                  x: i + 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: histogramCounts[i].toDouble(),
                                      width: 10,
                                      color: lightGreen,
                                    ),
                                  ],
                                );
                              }),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // History header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mood history',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: mainThemeColor,
                          ),
                        ),
                      ),
                      Text(
                        '${docs.length} entries',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // History list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final d = docs[i].data();
                      final score = (d['score'] as int?) ?? 0;
                      final emoji =
                          (d['emoji'] as String?) ?? _scoreToEmoji(score);
                      final dateStr = (d['date'] as String?) ?? '';
                      final ts = (d['timestamp'] as Timestamp?);
                      final timeDisplay = ts != null
                          ? DateFormat.yMMMd().add_jm().format(ts.toDate())
                          : dateStr;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: lightCream,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          title: Text(
                            'Score: $score',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: mainThemeColor,
                            ),
                          ),
                          subtitle: Text(
                            timeDisplay,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              final docRef = _fire
                                  .collection('mood_tracker')
                                  .doc(docs[i].id);
                              if (v == 'delete') {
                                await docRef.delete();
                              } else if (v == 'edit') {
                                _showEditDialog(docs[i].id, d);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    int score = (data['score'] as int?) ?? 5;
    String emoji = (data['emoji'] as String?) ?? _scoreToEmoji(score);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Edit mood entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 6,
                    children: _emojiOptions.map((e) {
                      return ChoiceChip(
                        label: Text(e, style: const TextStyle(fontSize: 18)),
                        selected: emoji == e,
                        selectedColor: accentGreen,
                        onSelected: (_) => setStateSB(() => emoji = e),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: score.toString(),
                    value: score.toDouble(),
                    activeColor: accentGreen,
                    onChanged: (v) => setStateSB(() {
                      score = v.round();
                      emoji = _scoreToEmoji(score);
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _fire.collection('mood_tracker').doc(docId).update({
                      'score': score,
                      'emoji': emoji,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
