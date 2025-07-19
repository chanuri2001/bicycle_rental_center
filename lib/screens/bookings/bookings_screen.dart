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
  DateTime? _pickupDateFilter;
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
              _allBookings[i].actualPickupDate != null) {
            final currentTime = DateTime.now();
            final pickupTime = _allBookings[i].actualPickupDate!;
            final activeTime = currentTime.difference(pickupTime);

            _allBookings[i] = _allBookings[i].copyWith(activeTime: activeTime);

            // Check if rental period is completed
            if (_allBookings[i].actualReturnDate == null &&
                currentTime.isAfter(_allBookings[i].returnDate)) {
              _allBookings[i] = _allBookings[i].copyWith(
                status: RentalStatus.completed,
                actualReturnDate: currentTime,
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
        userName: 'John Doe',
        userEmail: 'john@example.com',
        userPhone: '+1234567890',
        licenseNumber: 'DL123456789',
        bikes: [
          {
            'bike_id': 'bike1',
            'bike_name': 'Mountain Explorer',
            'bike_model': 'Trek X-Caliber',
            'quantity': 1,
            'daily_rate': 25.0,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        returnDate: DateTime.now().add(const Duration(days: 3)),
        totalCost: 50.0,
        deposit: 100.0,
        paymentMethod: 'card',
        status: RentalStatus.pending,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
      ),
      RentalRequest(
        id: '2',
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        userPhone: '+1234567891',
        licenseNumber: 'DL987654321',
        bikes: [
          {
            'bike_id': 'bike2',
            'bike_name': 'City Cruiser',
            'bike_model': 'Giant Escape',
            'quantity': 1,
            'daily_rate': 20.0,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        pickupDate: DateTime.now(),
        returnDate: DateTime.now().add(const Duration(days: 1)),
        totalCost: 20.0,
        deposit: 80.0,
        paymentMethod: 'card',
        status: RentalStatus.approved,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
        approvalDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
      ),
      RentalRequest(
        id: '3',
        userName: 'Mike Johnson',
        userEmail: 'mike@example.com',
        userPhone: '+1234567892',
        licenseNumber: 'DL456789123',
        bikes: [
          {
            'bike_id': 'bike3',
            'bike_name': 'Speed Demon',
            'bike_model': 'Specialized Allez',
            'quantity': 1,
            'daily_rate': 30.0,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 3)),
        pickupDate: DateTime.now().subtract(const Duration(hours: 2)),
        returnDate: DateTime.now().add(const Duration(hours: 22)),
        totalCost: 30.0,
        deposit: 120.0,
        paymentMethod: 'card',
        status: RentalStatus.active,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
        approvalDate: DateTime.now().subtract(const Duration(days: 1)),
        actualPickupDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
        activeTime: const Duration(hours: 2),
      ),
      RentalRequest(
        id: '4',
        userName: 'Sarah Wilson',
        userEmail: 'sarah@example.com',
        userPhone: '+1234567893',
        licenseNumber: 'DL789123456',
        bikes: [
          {
            'bike_id': 'bike4',
            'bike_name': 'Urban Rider',
            'bike_model': 'Cannondale Quick',
            'quantity': 1,
            'daily_rate': 25.0,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 5)),
        pickupDate: DateTime.now().subtract(const Duration(days: 2)),
        returnDate: DateTime.now().subtract(const Duration(days: 1)),
        totalCost: 25.0,
        deposit: 100.0,
        paymentMethod: 'card',
        status: RentalStatus.completed,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
        approvalDate: DateTime.now().subtract(const Duration(days: 3)),
        actualPickupDate: DateTime.now().subtract(const Duration(days: 2)),
        actualReturnDate: DateTime.now().subtract(const Duration(days: 1)),
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
                    booking.userEmail.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    booking.bikesSummary.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  List<RentalRequest> _getBookingsByStatus(RentalStatus? status) {
    if (status == null) return _filteredBookings;
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

    if (_pickupDateFilter != null) {
      pending =
          pending
              .where(
                (booking) =>
                    booking.pickupDate.year == _pickupDateFilter!.year &&
                    booking.pickupDate.month == _pickupDateFilter!.month &&
                    booking.pickupDate.day == _pickupDateFilter!.day,
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
                      'Pickup Date',
                      _pickupDateFilter,
                      (date) => setState(() => _pickupDateFilter = date),
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
                        _pickupDateFilter = null;
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.userName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // User contact info
            _buildInfoRow(Icons.email, booking.userEmail),
            _buildInfoRow(Icons.phone, booking.userPhone),
            if (booking.licenseNumber != null)
              _buildInfoRow(Icons.phone, booking.licenseNumber!),

            const SizedBox(height: 8),

            // Bikes summary
            Text(
              booking.bikesSummary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            Text(
              'Total bikes: ${booking.totalBikesCount}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        booking.formattedPickupDate,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        booking.formattedReturnDate,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '\$${booking.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deposit:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '\$${booking.deposit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Status-specific information
            if (booking.status == RentalStatus.active &&
                booking.activeTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Active for: ${booking.formattedActiveTime}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ),

            if (booking.status == RentalStatus.rejected &&
                booking.rejectionReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Reason: ${booking.rejectionReason}',
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),

            // Action buttons
            if (showPendingActions || showApprovedActions || showActiveActions)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildActionButtons(
                  booking,
                  showPendingActions,
                  showApprovedActions,
                  showActiveActions,
                ),
              ),

            // More options button
            Align(
              alignment: Alignment.bottomRight,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditBookingDialog(booking);
                  } else if (value == 'delete') {
                    _deleteBooking(booking);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Booking'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Booking'),
                      ),
                    ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
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
      ),
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
          onPressed: () => _markAsPickedUp(booking),
          icon: const Icon(Icons.directions_bike, size: 16),
          label: const Text('Mark as Picked Up'),
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
          onPressed: () => _markAsReturned(booking),
          icon: const Icon(Icons.assignment_turned_in, size: 16),
          label: const Text('Mark as Returned'),
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

  void _markAsPickedUp(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Mark as Picked Up',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Mark bicycle as picked up by ${booking.userName}? This will start the rental timer.',
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
                        actualPickupDate: DateTime.now(),
                        activeTime: Duration.zero,
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bicycle marked as picked up! Timer started.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _markAsReturned(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Mark as Returned',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Mark bicycle as returned by ${booking.userName}?',
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
                        actualReturnDate: DateTime.now(),
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bicycle marked as returned!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditBookingDialog(RentalRequest booking) {
    final pickupDateController = TextEditingController(
      text: booking.formattedPickupDate,
    );
    final returnDateController = TextEditingController(
      text: booking.formattedReturnDate,
    );

    // Create controllers for each bike's quantity
    final bikeQuantityControllers =
        booking.bikes.map((bike) {
          return TextEditingController(text: bike['quantity'].toString());
        }).toList();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.cardBackground,
                title: const Text(
                  'Edit Booking',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dates section
                      const Text(
                        'Dates',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pickupDateController,
                        decoration: const InputDecoration(
                          labelText: 'Pickup Date',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: booking.pickupDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            pickupDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: returnDateController,
                        decoration: const InputDecoration(
                          labelText: 'Return Date',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: booking.returnDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            returnDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Bikes section
                      const Text(
                        'Bikes',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...booking.bikes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bike = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bike['bike_name']} (${bike['bike_model']})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Daily rate: \$${bike['daily_rate']}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    final currentValue =
                                        int.tryParse(
                                          bikeQuantityControllers[index].text,
                                        ) ??
                                        0;
                                    if (currentValue > 1) {
                                      setState(() {
                                        bikeQuantityControllers[index].text =
                                            (currentValue - 1).toString();
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 40,
                                  child: TextField(
                                    controller: bikeQuantityControllers[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      // Validate input
                                      if (value.isEmpty ||
                                          int.tryParse(value) == null) {
                                        bikeQuantityControllers[index].text =
                                            '1';
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () {
                                    final currentValue =
                                        int.tryParse(
                                          bikeQuantityControllers[index].text,
                                        ) ??
                                        0;
                                    setState(() {
                                      bikeQuantityControllers[index].text =
                                          (currentValue + 1).toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
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
                      // Parse dates
                      final pickupParts = pickupDateController.text.split('/');
                      final newPickupDate = DateTime(
                        int.parse(pickupParts[2]),
                        int.parse(pickupParts[1]),
                        int.parse(pickupParts[0]),
                      );

                      final returnParts = returnDateController.text.split('/');
                      final newReturnDate = DateTime(
                        int.parse(returnParts[2]),
                        int.parse(returnParts[1]),
                        int.parse(returnParts[0]),
                      );

                      if (newReturnDate.isBefore(newPickupDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Return date must be after pickup date!',
                            ),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }

                      // Update bike quantities
                      final updatedBikes =
                          booking.bikes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final bike = Map<String, dynamic>.from(entry.value);
                            bike['quantity'] = int.parse(
                              bikeQuantityControllers[index].text,
                            );
                            return bike;
                          }).toList();

                      // Calculate new total cost
                      final rentalDays =
                          newReturnDate.difference(newPickupDate).inDays;
                      final newTotalCost = updatedBikes.fold(0.0, (sum, bike) {
                        return sum +
                            (bike['daily_rate'] *
                                bike['quantity'] *
                                rentalDays);
                      });

                      Navigator.pop(context);
                      setState(() {
                        final index = _allBookings.indexWhere(
                          (b) => b.id == booking.id,
                        );
                        if (index != -1) {
                          _allBookings[index] = booking.copyWith(
                            pickupDate: newPickupDate,
                            returnDate: newReturnDate,
                            bikes: updatedBikes,
                            totalCost: newTotalCost,
                          );
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _deleteBooking(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Delete Booking',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to delete booking for ${booking.userName}?',
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
                    _allBookings.removeWhere((b) => b.id == booking.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking deleted!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
    );
  }
}
