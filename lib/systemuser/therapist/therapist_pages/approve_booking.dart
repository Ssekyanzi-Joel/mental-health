import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TherapistBookingPage extends StatefulWidget {
  const TherapistBookingPage({super.key});

  @override
  State<TherapistBookingPage> createState() => _TherapistBookingPageState();
}

class _TherapistBookingPageState extends State<TherapistBookingPage>
    with TickerProviderStateMixin {
  // Modern professional color palette
  static const Color primaryBlue = const Color.fromARGB(
    255,
    15,
    40,
    20,
  ); // Professional Blue
  static const Color lightBlue = Color(0xFF3B82F6); // Lighter Blue
  static const Color accentTeal = Color(0xFF0891B2); // Teal Accent
  static const Color successGreen = Color(0xFF059669); // Success Green
  static const Color warningOrange = Color(0xFFF59E0B); // Warning Orange
  static const Color errorRed = Color(0xFFDC2626); // Error Red
  static const Color pureWhite = Color(0xFFFFFFFF); // Pure White
  static const Color lightGray = Color(0xFFF8FAFC); // Very Light Gray
  static const Color mediumGray = Color(0xFFE2E8F0); // Medium Gray
  static const Color darkGray = Color(0xFF475569); // Dark Gray
  static const Color softBlack = Color(0xFF1E293B); // Soft Black
  static const Color cardBackground = Color(0xFFFFFFFF); // White Cards
  static const Color shadowColor = Color(0x1A000000); // Subtle Shadow

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? therapistId = FirebaseAuth.instance.currentUser?.uid;

  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'All';
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? response,
  }) async {
    setState(() => _isLoading = true);

    try {
      final updateData = {
        'status': newStatus,
        'therapistId': therapistId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (response != null && response.isNotEmpty) {
        updateData['therapistResponse'] = response;
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);

      _showSnackBar(
        'Booking ${newStatus.toLowerCase()} successfully',
        newStatus == 'Accepted' ? successGreen : primaryBlue,
        newStatus == 'Accepted' ? Icons.check_circle : Icons.info,
      );
    } catch (e) {
      _showSnackBar('Failed to update booking', errorRed, Icons.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showResponseDialog(
    String bookingId,
    String currentStatus,
  ) async {
    final responseController = TextEditingController();
    String selectedStatus = currentStatus;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Update Booking',
                        style: TextStyle(
                          color: softBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Status',
                    style: TextStyle(
                      color: darkGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mediumGray),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        dropdownColor: pureWhite,
                        style: TextStyle(color: softBlack, fontSize: 16),
                        icon: Icon(Icons.keyboard_arrow_down, color: darkGray),
                        items: ['Pending', 'Accepted', 'Rejected', 'Completed']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(status),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatus = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Response Message (Optional)',
                    style: TextStyle(
                      color: darkGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: responseController,
                    maxLines: 4,
                    style: TextStyle(color: softBlack, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Add a personalized message for your client...',
                      hintStyle: TextStyle(color: darkGray.withOpacity(0.6)),
                      filled: true,
                      fillColor: lightGray,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: mediumGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: mediumGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: mediumGray),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: darkGray,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateBookingStatus(
                              bookingId,
                              selectedStatus,
                              response: responseController.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              15,
                              40,
                              20,
                            ),
                            foregroundColor: pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return successGreen;
      case 'rejected':
        return errorRed;
      case 'completed':
        return accentTeal;
      default:
        return warningOrange;
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? pureWhite : darkGray,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                selectedColor: primaryBlue,
                backgroundColor: pureWhite,
                checkmarkColor: pureWhite,
                side: BorderSide(
                  color: isSelected ? primaryBlue : mediumGray,
                  width: isSelected ? 2 : 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(QueryDocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'Pending';
    final name = data['name'] ?? 'Unknown Client';
    final email = data['email'] ?? 'No email';
    final phone = data['phone'] ?? 'No phone';
    final sessionType = data['sessionType'] ?? 'Therapy Session';
    final reason = data['reason'] ?? 'No reason provided';
    final dateTime = data['dateTime'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;
    final therapistResponse = data['therapistResponse'] as String?;

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  color: pureWhite,
                  surfaceTintColor: pureWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'update',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Update Status',
                            style: TextStyle(
                              color: softBlack,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'update') {
                      _showResponseDialog(booking.id, status);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: mediumGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: darkGray,
                      size: 16,
                    ),
                  ),
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
                // Client Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: pureWhite,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: softBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sessionType,
                                style: TextStyle(
                                  color: accentTeal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Information
                _buildInfoSection('Contact Information', [
                  _buildInfoRow(Icons.email_outlined, email),
                  _buildInfoRow(Icons.phone_outlined, phone),
                  if (dateTime != null)
                    _buildInfoRow(
                      Icons.schedule_outlined,
                      DateFormat(
                        'EEEE, MMM dd, yyyy • hh:mm a',
                      ).format(DateTime.parse(dateTime)),
                    ),
                ]),

                const SizedBox(height: 16),

                // Reason Section
                _buildInfoSection('Booking Details', [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reason,
                      style: TextStyle(
                        color: softBlack,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ]),

                // Therapist Response Section
                if (therapistResponse != null &&
                    therapistResponse.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection('Your Response', [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Text(
                        therapistResponse,
                        style: TextStyle(
                          color: softBlack,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ]),
                ],

                if (createdAt != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: darkGray.withOpacity(0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Requested ${DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt.toDate())}',
                        style: TextStyle(
                          color: darkGray.withOpacity(0.6),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
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

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: softBlack,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: primaryBlue, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: darkGray,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  Widget _buildBookingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.error_outline, color: errorRed, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: errorRed,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load bookings at the moment',
                    style: TextStyle(color: darkGray, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CircularProgressIndicator(
                      color: const Color.fromARGB(255, 15, 40, 20),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your bookings...',
                    style: TextStyle(
                      color: darkGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final allBookings = snapshot.data?.docs ?? [];
        final filteredBookings = _selectedFilter == 'All'
            ? allBookings
            : allBookings.where((booking) {
                final data = booking.data() as Map<String, dynamic>;
                return data['status'] == _selectedFilter;
              }).toList();

        return Column(
          children: [
            _buildFilterChips(),
            if (filteredBookings.isEmpty)
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.calendar_view_day_outlined,
                            size: 48,
                            color: darkGray,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _selectedFilter == 'All'
                              ? 'Your therapy bookings will appear here once clients start scheduling sessions'
                              : 'No ${_selectedFilter.toLowerCase()} bookings found',
                          style: TextStyle(color: darkGray, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) =>
                      _buildBookingCard(filteredBookings[index]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading analytics...',
                    style: TextStyle(
                      color: darkGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final bookings = snapshot.data?.docs ?? [];
        final totalBookings = bookings.length;
        final pendingBookings = bookings
            .where((doc) => (doc.data() as Map)['status'] == 'Pending')
            .length;
        final acceptedBookings = bookings
            .where((doc) => (doc.data() as Map)['status'] == 'Accepted')
            .length;
        final completedBookings = bookings
            .where((doc) => (doc.data() as Map)['status'] == 'Completed')
            .length;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Analytics',
                              style: TextStyle(
                                color: softBlack,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Overview of your therapy sessions',
                              style: TextStyle(color: darkGray, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        'Total Bookings',
                        totalBookings.toString(),
                        Icons.calendar_month_outlined,
                        primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        'Pending',
                        pendingBookings.toString(),
                        Icons.schedule_outlined,
                        warningOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        'Accepted',
                        acceptedBookings.toString(),
                        Icons.check_circle_outline,
                        successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        'Completed',
                        completedBookings.toString(),
                        Icons.done_all_outlined,
                        accentTeal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history,
                                color: accentTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                color: softBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: bookings.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      color: darkGray.withOpacity(0.6),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No activity yet',
                                      style: TextStyle(
                                        color: darkGray,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: bookings.take(5).map((booking) {
                                  final data =
                                      booking.data() as Map<String, dynamic>;
                                  final name = data['name'] ?? 'Unknown';
                                  final status = data['status'] ?? 'Pending';
                                  final createdAt =
                                      data['createdAt'] as Timestamp?;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: lightGray,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            _getStatusIcon(status),
                                            color: _getStatusColor(status),
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  color: softBlack,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    status,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                      status,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (createdAt != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'MMM dd',
                                                ).format(createdAt.toDate()),
                                                style: TextStyle(
                                                  color: darkGray,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                DateFormat(
                                                  'hh:mm a',
                                                ).format(createdAt.toDate()),
                                                style: TextStyle(
                                                  color: darkGray.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  color: softBlack,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: darkGray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (therapistId == null) {
      return Scaffold(
        backgroundColor: lightGray,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.login_outlined,
                    color: primaryBlue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Authentication Required',
                  style: TextStyle(
                    color: softBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please sign in as a therapist to access your dashboard',
                  style: TextStyle(color: darkGray, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightGray,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Clean App Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                decoration: BoxDecoration(
                  color: pureWhite,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: pureWhite,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Therapist Dashboard',
                            style: TextStyle(
                              color: softBlack,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your therapy bookings efficiently',
                            style: TextStyle(
                              color: darkGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Clean Tab Bar
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  labelColor: pureWhite,
                  unselectedLabelColor: darkGray,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Bookings'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Analytics'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildBookingsList(), _buildAnalytics()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
