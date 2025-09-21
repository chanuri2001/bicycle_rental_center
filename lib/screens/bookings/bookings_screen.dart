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
  Timer? _timer;
  Map<String, Duration> _activeTimers = {};

  // Filter variables
  DateTime? _pickupDateFilter;
  DateTime? _returnDateFilter;
  String _searchQuery = '';
  bool _showPartiallyPickedUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookings();
    _startTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Update active timers for each bicycle in active bookings
        for (var booking in _allBookings.where(
          (b) => b.status == RentalStatus.active,
        )) {
          for (var bike in booking.bikes.where(
            (b) =>
                b['actualPickupTime'] != null && b['actualReturnTime'] == null,
          )) {
            final bikeKey = '${booking.id}_${bike['bike_id']}';
            final pickupTime = bike['actualPickupTime'];
            final currentTime = DateTime.now();
            final activeTime = currentTime.difference(pickupTime);

            _activeTimers[bikeKey] = activeTime;

            // Check if rental period is completed for this bicycle
            if (currentTime.isAfter(booking.returnDate)) {
              bike['actualReturnTime'] = currentTime;
              _activeTimers.remove(bikeKey);
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

    // Mock data with separate accessories
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
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
          {
            'bike_id': 'bike2',
            'bike_name': 'City Cruiser',
            'bike_model': 'Giant Escape',
            'quantity': 1,
            'daily_rate': 20.0,
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
        ],
        accessories: [
          {
            'id': 'acc1',
            'name': 'Helmet',
            'price': 5.0,
            'quantity': 2,
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
          {
            'id': 'acc2',
            'name': 'Lock',
            'price': 3.0,
            'quantity': 1,
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
          {
            'id': 'acc3',
            'name': 'Insurance',
            'price': 10.0,
            'quantity': 1,
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        returnDate: DateTime.now().add(const Duration(days: 3)),
        totalCost: 135.0,
        deposit: 200.0,
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
            'bike_id': 'bike3',
            'bike_name': 'Speed Demon',
            'bike_model': 'Specialized Allez',
            'quantity': 2,
            'daily_rate': 30.0,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(hours: 2),
            ),
            'actualReturnTime': null,
          },
          {
            'bike_id': 'bike4',
            'bike_name': 'Urban Rider',
            'bike_model': 'Cannondale Quick',
            'quantity': 1,
            'daily_rate': 25.0,
            'actualPickupTime': null,
            'actualReturnTime': null,
          },
        ],
        accessories: [
          {
            'id': 'acc4',
            'name': 'Helmet',
            'price': 5.0,
            'quantity': 2,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(hours: 2),
            ),
            'actualReturnTime': null,
          },
          {
            'id': 'acc5',
            'name': 'Insurance',
            'price': 10.0,
            'quantity': 2,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(hours: 2),
            ),
            'actualReturnTime': null,
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        pickupDate: DateTime.now(),
        returnDate: DateTime.now().add(const Duration(days: 2)),
        totalCost: 180.0,
        deposit: 300.0,
        paymentMethod: 'card',
        status: RentalStatus.active,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
        approvalDate: DateTime.now().subtract(const Duration(hours: 3)),
        actualPickupDate: DateTime.now().subtract(const Duration(hours: 2)),
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
            'bike_id': 'bike5',
            'bike_name': 'Urban Rider',
            'bike_model': 'Cannondale Quick',
            'quantity': 1,
            'daily_rate': 25.0,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(days: 1, hours: 2),
            ),
            'actualReturnTime': DateTime.now().subtract(
              const Duration(hours: 2),
            ),
          },
          {
            'bike_id': 'bike6',
            'bike_name': 'Kids Bike',
            'bike_model': 'Trek Precaliber',
            'quantity': 1,
            'daily_rate': 15.0,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(days: 1),
            ),
            'actualReturnTime': DateTime.now().subtract(
              const Duration(hours: 4),
            ),
          },
        ],
        accessories: [
          {
            'id': 'acc6',
            'name': 'Helmet',
            'price': 5.0,
            'quantity': 1,
            'actualPickupTime': DateTime.now().subtract(
              const Duration(days: 1, hours: 2),
            ),
            'actualReturnTime': DateTime.now().subtract(
              const Duration(hours: 2),
            ),
          },
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 3)),
        pickupDate: DateTime.now().subtract(const Duration(days: 1)),
        returnDate: DateTime.now().add(const Duration(hours: 10)),
        totalCost: 85.0,
        deposit: 150.0,
        paymentMethod: 'card',
        status: RentalStatus.completed,
        termsAccepted: true,
        ageVerified: true,
        damageResponsibility: true,
        approvalDate: DateTime.now().subtract(const Duration(days: 2)),
        actualPickupDate: DateTime.now().subtract(const Duration(days: 1)),
        actualReturnDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
      ),
    ];

    // Initialize active timers for already active bikes
    for (var booking in _allBookings.where(
      (b) => b.status == RentalStatus.active,
    )) {
      for (var bike in booking.bikes.where(
        (b) => b['actualPickupTime'] != null && b['actualReturnTime'] == null,
      )) {
        final bikeKey = '${booking.id}_${bike['bike_id']}';
        _activeTimers[bikeKey] = DateTime.now().difference(
          bike['actualPickupTime'],
        );
      }
    }

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

    // Apply date filters
    if (_pickupDateFilter != null) {
      filtered =
          filtered
              .where(
                (booking) =>
                    booking.pickupDate.year == _pickupDateFilter!.year &&
                    booking.pickupDate.month == _pickupDateFilter!.month &&
                    booking.pickupDate.day == _pickupDateFilter!.day,
              )
              .toList();
    }

    if (_returnDateFilter != null) {
      filtered =
          filtered
              .where(
                (booking) =>
                    booking.returnDate.year == _returnDateFilter!.year &&
                    booking.returnDate.month == _returnDateFilter!.month &&
                    booking.returnDate.day == _returnDateFilter!.day,
              )
              .toList();
    }

    return filtered;
  }

  List<RentalRequest> _getBookingsByStatus(RentalStatus? status) {
    if (status == null) return _filteredBookings;

    if (status == RentalStatus.approved) {
      // For approved tab, show all approved bookings
      return _filteredBookings
          .where((booking) => booking.status == status)
          .toList();
    }

    return _filteredBookings
        .where((booking) => booking.status == status)
        .toList();
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
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateFilter(
                        'Pickup Date',
                        _pickupDateFilter,
                        (date) => setState(() => _pickupDateFilter = date),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateFilter(
                        'Return Date',
                        _returnDateFilter,
                        (date) => setState(() => _returnDateFilter = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_pickupDateFilter != null || _returnDateFilter != null)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _pickupDateFilter = null;
                            _returnDateFilter = null;
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
                        _buildBookingsList(
                          _filteredBookings,
                          showAllActions: true,
                        ),
                        _buildBookingsList(
                          _getBookingsByStatus(RentalStatus.pending),
                          showPendingActions: true,
                        ),
                        _buildBookingsList(
                          _getBookingsByStatus(RentalStatus.approved),
                          showApprovedActions: true,
                          showPartiallyPickedUpFilter: true,
                        ),
                        _buildBookingsList(
                          _getBookingsByStatus(RentalStatus.active),
                          showActiveActions: true,
                        ),
                        _buildBookingsList(
                          _getBookingsByStatus(RentalStatus.completed),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
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
    bool showPartiallyPickedUpFilter = false,
  }) {
    if (showPartiallyPickedUpFilter) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Show partially picked up:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Switch(
                  value: _showPartiallyPickedUp,
                  onChanged: (value) {
                    setState(() {
                      _showPartiallyPickedUp = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBookingListContent(
              _showPartiallyPickedUp
                  ? bookings
                  : bookings
                      .where((b) => !b.hasPartiallyPickedUpItems)
                      .toList(),
              showAllActions: showAllActions,
              showPendingActions: showPendingActions,
              showApprovedActions: showApprovedActions,
              showActiveActions: showActiveActions,
            ),
          ),
        ],
      );
    }

    return _buildBookingListContent(
      bookings,
      showAllActions: showAllActions,
      showPendingActions: showPendingActions,
      showApprovedActions: showApprovedActions,
      showActiveActions: showActiveActions,
    );
  }

  Widget _buildBookingListContent(
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
              _buildInfoRow(Icons.badge, booking.licenseNumber!),

            const SizedBox(height: 8),

            // Bikes section
            const Text(
              'Bicycles:',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var bike in booking.bikes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${bike['bike_name']} (${bike['quantity']}x)',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (bike['actualPickupTime'] != null)
                            IconButton(
                              icon: const Icon(Icons.timer, size: 16),
                              onPressed:
                                  () => _showBikeTimingDetails(bike, booking),
                            ),
                        ],
                      ),
                      if (bike['actualPickupTime'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                bike['actualReturnTime'] != null
                                    ? 'Returned at ${_formatTime(bike['actualReturnTime'])}'
                                    : 'Active for ${_formatDuration(_getActiveDuration(booking, bike))}',
                                style: TextStyle(
                                  color:
                                      bike['actualReturnTime'] != null
                                          ? AppColors.success
                                          : AppColors.warning,
                                  fontSize: 12,
                                ),
                              ),
                              if (bike['actualReturnTime'] == null &&
                                  (booking.status == RentalStatus.active ||
                                      booking.status == RentalStatus.approved))
                                TextButton(
                                  onPressed:
                                      () => _markBikeAsReturned(booking, bike),
                                  child: const Text(
                                    'Mark as Returned',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                Text(
                  'Total bikes: ${booking.totalBikesCount}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Accessories section
            if (booking.accessories != null && booking.accessories!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accessories:',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: [
                      for (var accessory in booking.accessories!)
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${accessory['name']} (${accessory['quantity']}x)',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (accessory['actualPickupTime'] != null)
                                  Text(
                                    accessory['actualReturnTime'] != null
                                        ? 'Returned'
                                        : 'Not returned',
                                    style: TextStyle(
                                      color:
                                          accessory['actualReturnTime'] != null
                                              ? AppColors.success
                                              : AppColors.warning,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (accessory['actualPickupTime'] != null &&
                                    accessory['actualReturnTime'] == null &&
                                    (booking.status == RentalStatus.active ||
                                        booking.status ==
                                            RentalStatus.approved))
                                  TextButton(
                                    onPressed:
                                        () => _markAccessoryAsReturned(
                                          booking,
                                          accessory,
                                        ),
                                    child: const Text(
                                      'Mark as Returned',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                    ],
                  ),
                ],
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
          onPressed: () => _showMarkItemsAsPickedUpDialog(booking),
          icon: const Icon(Icons.directions_bike, size: 16),
          label: const Text('Mark Items as Picked Up'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else if (showActiveActions) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              booking.allItemsReturned ? () => _markAsReturned(booking) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                booking.allItemsReturned ? AppColors.success : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Booking as Completed'),
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

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  Duration _getActiveDuration(
    RentalRequest booking,
    Map<String, dynamic> bike,
  ) {
    if (bike['actualReturnTime'] != null) {
      return bike['actualReturnTime'].difference(bike['actualPickupTime']);
    }

    final bikeKey = '${booking.id}_${bike['bike_id']}';
    if (_activeTimers.containsKey(bikeKey)) {
      return _activeTimers[bikeKey]!;
    }

    return Duration.zero;
  }

  void _showBikeTimingDetails(
    Map<String, dynamic> bike,
    RentalRequest booking,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              bike['bike_name'],
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model: ${bike['bike_model']}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pickup Time: ${bike['actualPickupTime'] != null ? _formatTime(bike['actualPickupTime']) : 'Not picked up yet'}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Return Time: ${bike['actualReturnTime'] != null ? _formatTime(bike['actualReturnTime']) : 'Not returned yet'}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (bike['actualPickupTime'] != null)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Active Duration: ${_formatDuration(_getActiveDuration(booking, bike))}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showMarkItemsAsPickedUpDialog(RentalRequest booking) {
    List<bool> bikePickedUpStatus = List.generate(
      booking.bikes.length,
      (index) => false,
    );

    List<bool> accessoryPickedUpStatus = List.generate(
      booking.accessories?.length ?? 0,
      (index) => false,
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.cardBackground,
                title: const Text(
                  'Mark Items as Picked Up',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select which items are being picked up now:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Bikes section
                      const Text(
                        'Bicycles:',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...booking.bikes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bike = entry.value;
                        return CheckboxListTile(
                          title: Text(
                            '${bike['bike_name']} (${bike['quantity']}x)',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          value: bikePickedUpStatus[index],
                          onChanged: (value) {
                            setState(() {
                              bikePickedUpStatus[index] = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        );
                      }).toList(),

                      // Accessories section
                      if (booking.accessories != null &&
                          booking.accessories!.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Accessories:',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...booking.accessories!.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final accessory = entry.value;
                              return CheckboxListTile(
                                title: Text(
                                  '${accessory['name']} (${accessory['quantity']}x)',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                value: accessoryPickedUpStatus[index],
                                onChanged: (value) {
                                  setState(() {
                                    accessoryPickedUpStatus[index] =
                                        value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                              );
                            }).toList(),
                          ],
                        ),
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
                      // Update the bikes with pickup times
                      List<Map<String, dynamic>> updatedBikes = [];
                      List<Map<String, dynamic>> updatedAccessories = [];
                      bool anyPickedUp = false;

                      // Update bikes
                      for (int i = 0; i < booking.bikes.length; i++) {
                        if (bikePickedUpStatus[i]) {
                          updatedBikes.add({
                            ...booking.bikes[i],
                            'actualPickupTime': DateTime.now(),
                          });
                          anyPickedUp = true;
                        } else {
                          updatedBikes.add(booking.bikes[i]);
                        }
                      }

                      // Update accessories
                      if (booking.accessories != null) {
                        for (int i = 0; i < booking.accessories!.length; i++) {
                          if (accessoryPickedUpStatus[i]) {
                            updatedAccessories.add({
                              ...booking.accessories![i],
                              'actualPickupTime': DateTime.now(),
                            });
                            anyPickedUp = true;
                          } else {
                            updatedAccessories.add(booking.accessories![i]);
                          }
                        }
                      }

                      if (anyPickedUp) {
                        setState(() {
                          // Check if all items are now picked up
                          final allItemsPickedUp =
                              updatedBikes.every(
                                (b) => b['actualPickupTime'] != null,
                              ) &&
                              (updatedAccessories.isEmpty ||
                                  updatedAccessories.every(
                                    (a) => a['actualPickupTime'] != null,
                                  ));

                          _allBookings[_allBookings.indexOf(booking)] = booking
                              .copyWith(
                                bikes: updatedBikes,
                                accessories: updatedAccessories,
                                status:
                                    allItemsPickedUp
                                        ? RentalStatus.active
                                        : RentalStatus.approved,
                                actualPickupDate: DateTime.now(),
                              );

                          // Start timers for picked up bikes
                          for (int i = 0; i < booking.bikes.length; i++) {
                            if (bikePickedUpStatus[i]) {
                              final bikeKey =
                                  '${booking.id}_${booking.bikes[i]['bike_id']}';
                              _activeTimers[bikeKey] = Duration.zero;
                            }
                          }
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Selected items marked as picked up!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one item'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _markBikeAsReturned(RentalRequest booking, Map<String, dynamic> bike) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Mark ${bike['bike_name']} as Returned',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Confirm that ${bike['bike_name']} has been returned?',
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
                  // Find the bike in the booking and update it
                  final bikeIndex = booking.bikes.indexWhere(
                    (b) => b['bike_id'] == bike['bike_id'],
                  );
                  if (bikeIndex != -1) {
                    List<Map<String, dynamic>> updatedBikes = List.from(
                      booking.bikes,
                    );
                    updatedBikes[bikeIndex] = {
                      ...updatedBikes[bikeIndex],
                      'actualReturnTime': DateTime.now(),
                    };

                    // Remove the timer for this bike
                    final bikeKey = '${booking.id}_${bike['bike_id']}';
                    _activeTimers.remove(bikeKey);

                    setState(() {
                      _allBookings[_allBookings.indexOf(booking)] = booking
                          .copyWith(bikes: updatedBikes);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${bike['bike_name']} marked as returned!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
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

  void _markAccessoryAsReturned(
    RentalRequest booking,
    Map<String, dynamic> accessory,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Mark ${accessory['name']} as Returned',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Confirm that ${accessory['name']} has been returned?',
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
                  if (booking.accessories != null) {
                    final accessoryIndex = booking.accessories!.indexWhere(
                      (a) => a['id'] == accessory['id'],
                    );
                    if (accessoryIndex != -1) {
                      List<Map<String, dynamic>> updatedAccessories = List.from(
                        booking.accessories!,
                      );
                      updatedAccessories[accessoryIndex] = {
                        ...updatedAccessories[accessoryIndex],
                        'actualReturnTime': DateTime.now(),
                      };

                      setState(() {
                        _allBookings[_allBookings.indexOf(booking)] = booking
                            .copyWith(accessories: updatedAccessories);
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${accessory['name']} marked as returned!',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
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

  void _markAsReturned(RentalRequest booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Mark as Completed',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Mark booking as completed for ${booking.userName}?',
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
                      content: Text('Booking marked as completed!'),
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

                      Navigator.pop(context);
                      setState(() {
                        final index = _allBookings.indexWhere(
                          (b) => b.id == booking.id,
                        );
                        if (index != -1) {
                          _allBookings[index] = booking.copyWith(
                            pickupDate: newPickupDate,
                            returnDate: newReturnDate,
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
