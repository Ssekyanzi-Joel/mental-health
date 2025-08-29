import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Modern therapy booking color palette
const Color primaryBackground = Color(0xFFF8F9FA);
const Color cardBackground = Color(0xFFFFFFFF);
const Color mainThemeColor = Color(0xFF2D5A3D);
const Color accentGreen = Color(0xFF6BCF7F);
const Color lightGreen = Color(0xFF9CDBA6);
const Color softOrange = Color(0xFFFF6B35);
const Color softBlue = Color(0xFF4A90E2);
const Color creamBackground = Color(0xFFFFF8E7);
const Color textSecondary = Color(0xFF6B7280);
const Color borderGreen = Color(0xFF9CDBA6);

class UserBookingPage extends StatefulWidget {
  const UserBookingPage({super.key});

  @override
  State<UserBookingPage> createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage>
    with TickerProviderStateMixin {
  // Modern therapy booking color palette
  static const Color primaryBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color mainThemeColor = Color(0xFF2D5A3D);
  static const Color accentGreen = Color(0xFF6BCF7F);
  static const Color lightGreen = Color(0xFF9CDBA6);
  static const Color softOrange = Color(0xFFFF6B35);
  static const Color softBlue = Color(0xFF4A90E2);
  static const Color creamBackground = Color(0xFFFFF8E7);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGreen = Color(0xFF9CDBA6);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  bool _isLoading = false;
  bool _isFormExpanded = false;

  late AnimationController _expandController;
  late AnimationController _fadeController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  String? _selectedGender;
  String? _selectedSessionType;
  String? _selectedExperience;
  DateTime? _selectedDateTime;

  // Dropdown options
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _sessionTypes = [
    'Individual Therapy',
    'Couples Therapy',
    'Family Therapy',
    'Group Therapy',
    'Online Session',
    'Initial Consultation',
  ];

  final List<String> _experienceOptions = ['Yes', 'No', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateTimeController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isFormExpanded = !_isFormExpanded;
    });

    if (_isFormExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: mainThemeColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: accentGreen,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: mainThemeColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _dateTimeController.text = DateFormat(
            'MMM dd, yyyy • hh:mm a',
          ).format(_selectedDateTime!);
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('bookings').add({
        'userId': userId,
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _selectedGender,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dateTime': _selectedDateTime?.toIso8601String(),
        'sessionType': _selectedSessionType,
        'reason': _reasonController.text.trim(),
        'previousExperience': _selectedExperience,
        'notes': _notesController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Booking submitted successfully!');
      _clearForm();
      _toggleForm();
    } catch (e) {
      _showErrorSnackBar('Failed to submit booking. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dateTimeController.clear();
    _reasonController.clear();
    _notesController.clear();

    setState(() {
      _selectedGender = null;
      _selectedSessionType = null;
      _selectedExperience = null;
      _selectedDateTime = null;
    });
  }

  Future<void> _deleteBooking(String bookingId) async {
    final shouldDelete = await _showDeleteDialog();
    if (shouldDelete != true) return;

    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      _showSuccessSnackBar('Booking deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete booking');
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Booking?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          hintStyle: TextStyle(color: mainThemeColor.withOpacity(0.5)),
          filled: true,
          fillColor: primaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderGreen),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        dropdownColor: cardBackground,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          filled: true,
          fillColor: primaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderGreen),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        validator: validator,
      ),
    );
  }

  Widget _buildBookingForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainThemeColor, mainThemeColor.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            GestureDetector(
              onTap: _toggleForm,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Therapy Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Schedule your appointment',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isFormExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    heightFactor: _expandAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Personal Information
                    _buildFormField(
                      controller: _nameController,
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                      validator: (value) => value?.trim().isEmpty == true
                          ? 'Name is required'
                          : null,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: _ageController,
                            label: 'Age',
                            hint: 'Your age',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildDropdownField(
                            label: 'Gender',
                            value: _selectedGender,
                            items: _genderOptions,
                            onChanged: (value) =>
                                setState(() => _selectedGender = value),
                          ),
                        ),
                      ],
                    ),

                    _buildFormField(
                      controller: _emailController,
                      label: 'Email Address *',
                      hint: 'your.email@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.trim().isEmpty == true) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    _buildFormField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      hint: '+1 (555) 123-4567',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.trim().isEmpty == true
                          ? 'Phone number is required'
                          : null,
                    ),

                    _buildFormField(
                      controller: _dateTimeController,
                      label: 'Preferred Date & Time *',
                      hint: 'Select your preferred appointment time',
                      readOnly: true,
                      onTap: _selectDateTime,
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white70,
                      ),
                      validator: (value) => value?.trim().isEmpty == true
                          ? 'Please select date and time'
                          : null,
                    ),

                    _buildDropdownField(
                      label: 'Session Type *',
                      value: _selectedSessionType,
                      items: _sessionTypes,
                      onChanged: (value) =>
                          setState(() => _selectedSessionType = value),
                      validator: (value) =>
                          value == null ? 'Please select session type' : null,
                    ),

                    _buildFormField(
                      controller: _reasonController,
                      label: 'Reason for Booking *',
                      hint: 'Describe your primary concerns or goals',
                      maxLines: 3,
                      validator: (value) => value?.trim().isEmpty == true
                          ? 'Please provide a reason'
                          : null,
                    ),

                    _buildDropdownField(
                      label: 'Previous Therapy Experience',
                      value: _selectedExperience,
                      items: _experienceOptions,
                      onChanged: (value) =>
                          setState(() => _selectedExperience = value),
                    ),

                    _buildFormField(
                      controller: _notesController,
                      label: 'Additional Notes',
                      hint: 'Any additional information you\'d like to share',
                      maxLines: 3,
                      validator: null, // Optional field
                    ),

                    const SizedBox(height: 8),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: accentGreen.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Submit Booking Request',
                                    style: TextStyle(
                                      fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(QueryDocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'Pending';
    final createdAt = data['createdAt'] as Timestamp?;
    final dateTime = data['dateTime'] as String?;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardBackground, cardBackground],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (status.toLowerCase() == 'pending')
                  IconButton(
                    onPressed: () => _deleteBooking(booking.id),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    tooltip: 'Delete booking',
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['sessionType'] ?? 'Therapy Session',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['reason'] ?? 'No reason provided',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details
                if (dateTime != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(DateTime.parse(dateTime)),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (createdAt != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Requested on ${DateFormat('MMM dd, yyyy').format(createdAt.toDate())}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        backgroundColor: primaryBackground,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderGreen),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login_rounded, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Please sign in to continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Clean header section
          SliverToBoxAdapter(child: _buildHeaderSection()),

          // Upcoming session card
          SliverToBoxAdapter(child: _buildUpcomingSession()),

          // Session filter
          SliverToBoxAdapter(child: _buildSessionFilter()),

          // Sessions list
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('bookings')
                .where('userId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: _buildErrorState());
              }

              final bookings = snapshot.data?.docs ?? [];

              if (bookings.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTherapistCard(bookings[index]),
                  childCount: bookings.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleForm,
        backgroundColor: softOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Book Session",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Modern header section
Widget _buildHeaderSection() {
  return Container(
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [cardBackground, primaryBackground],
      ),
    ),
    child: SafeArea(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentGreen.withOpacity(0.2),
            child: Icon(Icons.person_rounded, color: mainThemeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Sessions",
                  style: TextStyle(
                    color: mainThemeColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Manage your therapy appointments",
                  style: TextStyle(color: textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: softOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: softOrange,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: softOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Upcoming session card
Widget _buildUpcomingSession() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: creamBackground,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: mainThemeColor.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Session",
          style: TextStyle(
            color: mainThemeColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop&crop=face",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sahana V",
                    style: TextStyle(
                      color: mainThemeColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Msc in Clinical Psychology",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "7:30 PM - 8:30 PM",
          style: TextStyle(
            color: mainThemeColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Join session logic
            },
            icon: const Icon(Icons.videocam_rounded, size: 20),
            label: const Text("Join Now"),
            style: ElevatedButton.styleFrom(
              backgroundColor: softOrange,
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
  );
}

// Session filter
Widget _buildSessionFilter() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mainThemeColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "All Sessions",
                style: TextStyle(
                  color: mainThemeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: mainThemeColor,
                size: 20,
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mainThemeColor.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.filter_list_rounded,
            color: mainThemeColor,
            size: 20,
          ),
        ),
      ],
    ),
  );
}

// Therapist card (redesigned booking card)
Widget _buildTherapistCard(QueryDocumentSnapshot booking) {
  final data = booking.data() as Map<String, dynamic>;
  final status = data['status'] ?? 'Pending';
  final dateTime = data['dateTime'] as String?;
  final sessionType = data['sessionType'] ?? 'Therapy Session';

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: mainThemeColor.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: mainThemeColor.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop&crop=face",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sahana V",
                    style: TextStyle(
                      color: mainThemeColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Msc in Clinical Psychology",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              dateTime != null
                  ? DateFormat('dd MMM \'yy').format(DateTime.parse(dateTime))
                  : "Date TBD",
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 24),
            Icon(Icons.access_time_rounded, color: textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              dateTime != null
                  ? DateFormat('h:mm a').format(DateTime.parse(dateTime))
                  : "Time TBD",
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (status.toLowerCase() == 'accepted') ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reschedule logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: softOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Reschedule",
                    style: TextStyle(color: softOrange),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Join now logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Join Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else if (status.toLowerCase() == 'completed') ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Re-book logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: softOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Re-book", style: TextStyle(color: softOrange)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View profile logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: mainThemeColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "View Profile",
                    style: TextStyle(color: mainThemeColor),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

// Error state
Widget _buildErrorState() {
  return Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading sessions',
            style: TextStyle(
              color: mainThemeColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

// Empty state
Widget _buildEmptyState() {
  return Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 48,
              color: accentGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No sessions yet',
            style: TextStyle(
              color: mainThemeColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book your first therapy session to get started',
            style: TextStyle(color: textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
