import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Refined balanced color palette
  static const Color primaryDark =   Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color secondaryDark = Color(0xFF2A2D3A);
  static const Color accentTeal = Color(0xFF00C896);
  static const Color softTeal = Color(0xFF4ECDC4);
  static const Color lightGrey = Color(0xFFE8EBF0);
  static const Color mediumGrey = Color(0xFF8B949E);
  static const Color cardBackground = Colors.white;
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundWhite = Color(0xFFF8FAFC);
  static const Color riskColor = Color(0xFFFEE2E2);
  static const Color riskBorder = Color(0xFFFCA5A5);

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
        // Haptic feedback
        HapticFeedback.lightImpact();

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
                  child: const Icon(Icons.check, color: successColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Report submitted successfully",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: successColor,
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
        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Error submitting report: $e",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: errorColor,
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
      return errorColor;
    }
    return accentTeal;
  }

  bool _isRiskQuestion(int index) => index >= 11 && index <= 12;

  Widget _buildProgressIndicator() {
    double progress = _completedQuestions / questions.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Assessment Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$_completedQuestions/${questions.length}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(accentTeal),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress * 100).toInt()}% completed",
            style: TextStyle(
              fontSize: 13,
              color: mediumGrey,
              fontWeight: FontWeight.w500,
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
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                  accentTeal.withOpacity(0.1),
                  softTeal.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentTeal.withOpacity(0.2)),
            ),
            child: Icon(Icons.assignment_rounded, color: accentTeal, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Therapy Assessment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: lightGrey),
                  ),
                  child: Text(
                    "Patient: ${widget.userName}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${questions.length} comprehensive questions",
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumGrey,
                    fontWeight: FontWeight.w500,
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
        color: isRisk ? riskColor : cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRisk
              ? riskBorder
              : hasContent
              ? accentTeal.withOpacity(0.5)
              : lightGrey,
          width: isRisk || hasContent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isRisk
                ? errorColor.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
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
                    color: _getQuestionColor(index).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getQuestionColor(index).withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    _getQuestionIcon(index),
                    color: _getQuestionColor(index),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: mediumGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Question ${index + 1}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mediumGrey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        questions[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isRisk ? errorColor : primaryDark,
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
                      color: successColor,
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
              style: TextStyle(color: primaryDark, fontSize: 15, height: 1.4),
              decoration: InputDecoration(
                hintText: isRisk
                    ? "Please provide detailed risk assessment..."
                    : "Share your professional assessment...",
                hintStyle: TextStyle(
                  color: mediumGrey.withOpacity(0.7),
                  fontSize: 15,
                ),
                fillColor: backgroundWhite,
                filled: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _getQuestionColor(index),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: errorColor, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: errorColor, width: 2),
                ),
              ),
              validator: (value) => value!.trim().isEmpty
                  ? "Please provide your assessment for this question"
                  : null,
            ),
            if (isRisk) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: errorColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This is a critical risk assessment question",
                        style: TextStyle(
                          fontSize: 12,
                          color: errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Assessment Report",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
                  color: accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentTeal.withOpacity(0.3)),
                ),
                child: Text(
                  "${((_completedQuestions / questions.length) * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: accentTeal,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Submitting Report",
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please wait while we process your assessment...",
                      style: TextStyle(color: mediumGrey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  const SizedBox(height: 20),
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
      floatingActionButton: AnimatedScale(
        scale: _loading ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentTeal.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _loading ? null : submitReport,
            icon: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            label: Text(
              _loading ? "Submitting..." : "Submit Assessment",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            backgroundColor: accentTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ),
      ),
    );
  }
}
