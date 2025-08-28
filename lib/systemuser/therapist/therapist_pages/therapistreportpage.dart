import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:mind_aware_application/systemuser/therapist/therapist_pages/therapist_report_dashboard.dart';

class TherapistReportPage extends StatefulWidget {
  final String userId;
  final String userName;

  const TherapistReportPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<TherapistReportPage> createState() => _TherapistReportPageState();
}

class _TherapistReportPageState extends State<TherapistReportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  int _completedQuestions = 0;

  // Modern green color palette
  static const Color primaryGreen = Color.fromRGBO(25, 53, 30, 1);
  static const Color accentGreen = Color.fromRGBO(
    34,
    197,
    94,
    1,
  ); // Modern emerald
  static const Color lightGreen = Color.fromRGBO(
    134,
    239,
    172,
    1,
  ); // Light emerald
  // ignore: unused_field
  static const Color darkGreen = Color.fromRGBO(20, 83, 45, 1); // Dark emerald
  // ignore: unused_field
  static const Color surfaceGreen = Color.fromRGBO(22, 101, 52, 0.1);
  static const Color cardGreen = Color.fromRGBO(30, 58, 35, 1);
  static const Color borderGreen = Color.fromRGBO(74, 222, 128, 0.2);

  final List<String> questions = [
    "How is the user's overall mood?",
    "Does the user show signs of anxiety?",
    "Does the user participate in therapy sessions?",
    "How is the user's sleep pattern?",
    "How is the user's appetite?",
    "Is the user showing signs of improvement?",
    "Any social interaction changes?",
    "Any emotional outbursts?",
    "Is medication being taken as prescribed?",
    "Any physical health concerns?",
    "User's engagement level in activities?",
    "Any risk of self-harm?",
    "Any risk of harming others?",
    "Family or social support situation?",
    "Final assessment and recommendation?",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    for (int i = 0; i < questions.length; i++) {
      _controllers[i] = TextEditingController();
      _focusNodes[i] = FocusNode();

      // Listen for text changes to update progress
      _controllers[i]!.addListener(() {
        _updateProgress();
      });
    }

    _animationController.forward();
  }

  void _updateProgress() {
    int completed = 0;
    for (var controller in _controllers.values) {
      if (controller.text.trim().isNotEmpty) {
        completed++;
      }
    }
    if (completed != _completedQuestions) {
      setState(() {
        _completedQuestions = completed;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final therapistId = FirebaseAuth.instance.currentUser!.uid;

      final Map<String, String> answers = {};
      for (int i = 0; i < questions.length; i++) {
        answers["q${i + 1}"] = _controllers[i]!.text.trim();
      }

      await FirebaseFirestore.instance.collection("reports").add({
        "userId": widget.userId,
        "userName": widget.userName,
        "therapistId": therapistId,
        "questions": answers,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: accentGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Report submitted successfully",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: accentGreen,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Error: $e")),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  IconData _getQuestionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_satisfied_alt_rounded;
      case 1:
        return Icons.psychology_outlined;
      case 2:
        return Icons.groups_rounded;
      case 3:
        return Icons.bedtime_rounded;
      case 4:
        return Icons.restaurant_rounded;
      case 5:
        return Icons.trending_up_rounded;
      case 6:
        return Icons.people_alt_rounded;
      case 7:
        return Icons.sentiment_very_dissatisfied_rounded;
      case 8:
        return Icons.medication_liquid_rounded;
      case 9:
        return Icons.health_and_safety_rounded;
      case 10:
        return Icons.sports_rounded;
      case 11:
        return Icons.warning_amber_rounded;
      case 12:
        return Icons.dangerous_rounded;
      case 13:
        return Icons.family_restroom_rounded;
      case 14:
        return Icons.assessment_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getQuestionColor(int index) {
    if (index >= 11 && index <= 12) {
      return Colors.red.shade400;
    }
    return accentGreen;
  }

  bool _isRiskQuestion(int index) => index >= 11 && index <= 12;

  Widget _buildProgressIndicator() {
    double progress = _completedQuestions / questions.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: lightGreen.withOpacity(0.8),
                ),
              ),
              Text(
                "$_completedQuestions/${questions.length}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: lightGreen.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: primaryGreen.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardGreen, cardGreen.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGreen, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentGreen.withOpacity(0.2),
                  accentGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.assignment_rounded, color: accentGreen, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Therapy Assessment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: lightGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Patient: ${widget.userName}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${questions.length} comprehensive questions",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final isRisk = _isRiskQuestion(index);
    final hasContent = _controllers[index]!.text.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isRisk ? Colors.red.shade900.withOpacity(0.1) : cardGreen,
            isRisk
                ? Colors.red.shade800.withOpacity(0.05)
                : cardGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRisk
              ? Colors.red.shade400.withOpacity(0.3)
              : hasContent
              ? accentGreen.withOpacity(0.5)
              : borderGreen,
          width: isRisk
              ? 2
              : hasContent
              ? 2
              : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isRisk
                ? Colors.red.withOpacity(0.1)
                : accentGreen.withOpacity(0.05),
            blurRadius: hasContent ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getQuestionColor(index).withOpacity(0.2),
                        _getQuestionColor(index).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getQuestionColor(index).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getQuestionIcon(index),
                    color: _getQuestionColor(index),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${index + 1}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        questions[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isRisk ? Colors.red.shade300 : lightGreen,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasContent)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLines: 3,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: "Share your professional assessment...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 15,
                ),
                fillColor: primaryGreen.withOpacity(0.8),
                filled: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _getQuestionColor(index).withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _getQuestionColor(index).withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _getQuestionColor(index),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
              ),
              validator: (value) => value!.trim().isEmpty
                  ? "Please provide your assessment for this question"
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        title: Text(
          "Assessment Report",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentGreen.withOpacity(0.3)),
                ),
                child: Text(
                  "${((_completedQuestions / questions.length) * 100).toInt()}%",
                  style: TextStyle(
                    color: lightGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryGreen,
              primaryGreen.withOpacity(0.95),
              const Color.fromRGBO(15, 40, 20, 1),
            ],
          ),
        ),
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardGreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              color: accentGreen,
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Submitting Report",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please wait while we process your assessment...",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return _buildQuestionCard(index);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _loading ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentGreen.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _loading ? null : submitReport,
            icon: _loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            label: Text(
              _loading ? "Submitting..." : "Submit Assessment",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            backgroundColor: accentGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ),
      ),
    );
  }
}
