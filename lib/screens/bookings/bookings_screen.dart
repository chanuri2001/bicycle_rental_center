import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../models/rental_request.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<RentalRequest> _allBookings = [];
  bool _isLoading = true;
  Timer? _activeTimer;

  // Filter variables for pending bookings
  DateTime? _submissionDateFilter;
  DateTime? _startDateFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookings();
    _startActiveTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeTimer?.cancel();
    super.dispose();
  }

  void _startActiveTimer() {
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Update active timers
        for (int i = 0; i < _allBookings.length; i++) {
          if (_allBookings[i].status == RentalStatus.active &&
              _allBookings[i].pickupDate != null) {
            final currentTime = DateTime.now();
            final pickupTime = _allBookings[i].pickupDate!;
            final activeTime = currentTime.difference(pickupTime);

            _allBookings[i] = _allBookings[i].copyWith(activeTime: activeTime);

            // Check if rental period is completed
            if (currentTime.isAfter(_allBookings[i].endDate)) {
              _allBookings[i] = _allBookings[i].copyWith(
                status: RentalStatus.completed,
                returnDate: currentTime,
              );
            }
          }
        }
      });
    });
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _allBookings = [
      RentalRequest(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        userPhone: '+1234567890',
        bicycleId: 'bike1',
        bicycleName: 'Mountain Explorer',
        bicycleModel: 'Trek X-Caliber',
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        durationDays: 2,
        totalCost: 50.0,
        status: RentalStatus.pending,
        notes: 'Need for weekend trip',
      ),
      RentalRequest(
        id: '2',
        userId: 'user2',
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        userPhone: '+1234567891',
        bicycleId: 'bike2',
        bicycleName: 'City Cruiser',
        bicycleModel: 'Giant Escape',
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        durationDays: 1,
        totalCost: 25.0,
        status: RentalStatus.approved,
        approvalDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
      ),
      RentalRequest(
        id: '3',
        userId: 'user3',
        userName: 'Mike Johnson',
        userEmail: 'mike@example.com',
        userPhone: '+1234567892',
        bicycleId: 'bike3',
        bicycleName: 'Speed Demon',
        bicycleModel: 'Specialized Allez',
        submissionDate: DateTime.now().subtract(const Duration(days: 3)),
        startDate: DateTime.now().subtract(const Duration(hours: 2)),
        endDate: DateTime.now().add(const Duration(hours: 22)),
        durationDays: 1,
        totalCost: 30.0,
        status: RentalStatus.active,
        approvalDate: DateTime.now().subtract(const Duration(days: 1)),
        pickupDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
        activeTime: const Duration(hours: 2),
      ),
      RentalRequest(
        id: '4',
        userId: 'user4',
        userName: 'Sarah Wilson',
        userEmail: 'sarah@example.com',
        userPhone: '+1234567893',
        bicycleId: 'bike4',
        bicycleName: 'Urban Rider',
        bicycleModel: 'Cannondale Quick',
        submissionDate: DateTime.now().subtract(const Duration(days: 5)),
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        durationDays: 1,
        totalCost: 25.0,
        status: RentalStatus.completed,
        approvalDate: DateTime.now().subtract(const Duration(days: 3)),
        pickupDate: DateTime.now().subtract(const Duration(days: 2)),
        returnDate: DateTime.now().subtract(const Duration(days: 1)),
        approvedBy: 'Admin',
        activeTime: const Duration(hours: 24),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<RentalRequest> get _filteredBookings {
    List<RentalRequest> filtered = _allBookings;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (booking) =>
                    booking.userName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    booking.bicycleName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    booking.bicycleModel.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  List<RentalRequest> _getBookingsByStatus(RentalStatus? status) {
    if (status == null) return _filteredBookings; // All bookings
    return _filteredBookings
        .where((booking) => booking.status == status)
        .toList();
  }

  List<RentalRequest> get _pendingBookingsFiltered {
    List<RentalRequest> pending = _getBookingsByStatus(RentalStatus.pending);

    if (_submissionDateFilter != null) {
      pending =
          pending
              .where(
                (booking) =>
                    booking.submissionDate.year ==
                        _submissionDateFilter!.year &&
                    booking.submissionDate.month ==
                        _submissionDateFilter!.month &&
                    booking.submissionDate.day == _submissionDateFilter!.day,
              )
              .toList();
    }

    if (_startDateFilter != null) {
      pending =
          pending
              .where(
                (booking) =>
                    booking.startDate.year == _startDateFilter!.year &&
                    booking.startDate.month == _startDateFilter!.month &&
                    booking.startDate.day == _startDateFilter!.day,
              )
              .toList();
    }

    return pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'All (${_filteredBookings.length})'),
            Tab(
              text:
                  'Pending (${_getBookingsByStatus(RentalStatus.pending).length})',
            ),
            Tab(
              text:
                  'Approved (${_getBookingsByStatus(RentalStatus.approved).length})',
            ),
            Tab(
              text:
                  'Active (${_getBookingsByStatus(RentalStatus.active).length})',
            ),
            Tab(
              text:
                  'Completed (${_getBookingsByStatus(RentalStatus.completed).length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search bookings...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Tab Content
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllBookingsTab(),
                        _buildPendingBookingsTab(),
                        _buildApprovedBookingsTab(),
                        _buildActiveBookingsTab(),
                        _buildCompletedBookingsTab(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBookingsTab() {
    return _buildBookingsList(_filteredBookings, showAllActions: true);
  }

  Widget _buildPendingBookingsTab() {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDateFilter(
                      'Submission Date',
                      _submissionDateFilter,
                      (date) => setState(() => _submissionDateFilter = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateFilter(
                      'Start Date',
                      _startDateFilter,
                      (date) => setState(() => _startDateFilter = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _submissionDateFilter = null;
                        _startDateFilter = null;
                      });
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildBookingsList(
            _pendingBookingsFiltered,
            showPendingActions: true,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedBookingsTab() {
    return _buildBookingsList(
      _getBookingsByStatus(RentalStatus.approved),
      showApprovedActions: true,
    );
  }

  Widget _buildActiveBookingsTab() {
    return _buildBookingsList(
      _getBookingsByStatus(RentalStatus.active),
      showActiveActions: true,
    );
  }

  Widget _buildCompletedBookingsTab() {
    return _buildBookingsList(_getBookingsByStatus(RentalStatus.completed));
  }

  Widget _buildDateFilter(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color:
                      selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onDateSelected(null),
                child: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    List<RentalRequest> bookings, {
    bool showAllActions = false,
    bool showPendingActions = false,
    bool showApprovedActions = false,
    bool showActiveActions = false,
  }) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(
            booking,
            showAllActions: showAllActions,
            showPendingActions: showPendingActions,
            showApprovedActions: showApprovedActions,
            showActiveActions: showActiveActions,
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    RentalRequest booking, {
    bool showAllActions = false,
    bool showPendingActions = false,
    bool showApprovedActions = false,
    bool showActiveActions = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        booking.bicycleName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bicycle Info
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bike,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.bicycleName} - ${booking.bicycleModel}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'Submitted: ${booking.formattedSubmissionDate}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.play_arrow,
                        'Start: ${booking.formattedStartDate}',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.stop,
                        'End: ${booking.formattedEndDate}',
                      ),
                    ),
                  ],
                ),

                // Contact Info
                const SizedBox(height: 8),
                _buildInfoRow(Icons.email, booking.userEmail),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.phone, booking.userPhone),

                // Cost
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  '\$${booking.totalCost.toStringAsFixed(2)} (${booking.durationDays} days)',
                ),

                // Active Timer
                if (booking.status == RentalStatus.active &&
                    booking.activeTime != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active Time: ${booking.formattedActiveTime}',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Notes
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, color: AppColors.info, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.notes!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action Buttons
                if (showPendingActions ||
                    showApprovedActions ||
                    showActiveActions)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: _buildActionButtons(
                      booking,
                      showPendingActions,
                      showApprovedActions,
                      showActiveActions,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    RentalRequest booking,
    bool showPendingActions,
    bool showApprovedActions,
    bool showActiveActions,
  ) {
    if (showPendingActions) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approveBooking(booking),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rejectBooking(booking),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (showApprovedActions) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handOverBicycle(booking),
          icon: const Icon(Icons.directions_bike, size: 16),
          label: const Text('Hand Over Bicycle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else if (showActiveActions) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _completeBicycleReturn(booking),
          icon: const Icon(Icons.assignment_turned_in, size: 16),
          label: const Text('Complete Return'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return AppColors.warning;
      case RentalStatus.approved:
        return AppColors.info;
      case RentalStatus.active:
        return AppColors.success;
      case RentalStatus.completed:
        return AppColors.primary;
      case RentalStatus.rejected:
        return AppColors.danger;
    }
  }

  void _approveBooking(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Approve Booking',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Approve booking for ${booking.userName}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    final index = _allBookings.indexWhere(
                      (b) => b.id == booking.id,
                    );
                    if (index != -1) {
                      _allBookings[index] = booking.copyWith(
                        status: RentalStatus.approved,
                        approvalDate: DateTime.now(),
                        approvedBy: 'Admin',
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking approved successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Approve',
                  style: TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
    );
  }

  void _rejectBooking(RentalRequest booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Reject Booking',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reject booking for ${booking.userName}?',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    final index = _allBookings.indexWhere(
                      (b) => b.id == booking.id,
                    );
                    if (index != -1) {
                      _allBookings[index] = booking.copyWith(
                        status: RentalStatus.rejected,
                        rejectionReason: reasonController.text.trim(),
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking rejected!'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                },
                child: const Text(
                  'Reject',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
    );
  }

  void _handOverBicycle(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Hand Over Bicycle',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Hand over bicycle to ${booking.userName}? This will start the rental timer.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    final index = _allBookings.indexWhere(
                      (b) => b.id == booking.id,
                    );
                    if (index != -1) {
                      _allBookings[index] = booking.copyWith(
                        status: RentalStatus.active,
                        pickupDate: DateTime.now(),
                        activeTime: Duration.zero,
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bicycle handed over! Timer started.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Hand Over',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _completeBicycleReturn(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Complete Return',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Mark bicycle return as completed for ${booking.userName}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    final index = _allBookings.indexWhere(
                      (b) => b.id == booking.id,
                    );
                    if (index != -1) {
                      _allBookings[index] = booking.copyWith(
                        status: RentalStatus.completed,
                        returnDate: DateTime.now(),
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bicycle return completed!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Complete',
                  style: TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
    );
  }
}
