import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TherapistMoodTrackerPage extends StatefulWidget {
  const TherapistMoodTrackerPage({super.key});

  @override
  State<TherapistMoodTrackerPage> createState() => _TherapistMoodTrackerPageState();
}

class _TherapistMoodTrackerPageState extends State<TherapistMoodTrackerPage> {
  String? selectedUser; // for filtering

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Mood Tracker Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Filter Dropdown
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("mood_tracker").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final users = snapshot.data!.docs.map((doc) => doc['userName'] as String).toSet().toList();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Filter by User",
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedUser,
                  items: users.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedUser = val;
                    });
                  },
                ),
              );
            },
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedUser == null
                  ? FirebaseFirestore.instance.collection("mood_tracker").orderBy("date", descending: true).snapshots()
                  : FirebaseFirestore.instance.collection("mood_tracker").where("userName", isEqualTo: selectedUser).orderBy("date", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No mood tracker data found."));
                }

                // Graph Data Preparation
                List<FlSpot> lineSpots = [];
                List<BarChartGroupData> barGroups = [];
                Map<int, int> histogram = {};

                for (int i = 0; i < docs.length; i++) {
                  final doc = docs[i];
                  final rating = (doc['rating'] ?? 0).toDouble();
                  lineSpots.add(FlSpot(i.toDouble(), rating));
                  barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: rating, color: Colors.blue)]));
                  histogram[rating.toInt()] = (histogram[rating.toInt()] ?? 0) + 1;
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // LINE GRAPH
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: lineSpots,
                                barWidth: 3,
                                color: Colors.teal,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // BAR GRAPH
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            barGroups: barGroups,
                          ),
                        ),
                      ),

                      // HISTOGRAM GRAPH
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            barGroups: histogram.entries
                                .map((e) => BarChartGroupData(
                                      x: e.key,
                                      barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.orange)],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      // LIST OF RESPONSES
                      ListView.builder(
                        itemCount: docs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(doc['rating'].toString()),
                              ),
                              title: Text("${doc['userName']} - ${doc['question']}"),
                              subtitle: Text("${doc['answer']} \n${doc['date'].toDate()}"),
                              isThreeLine: true,
                            ),
                          );
                        },
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
}
