import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/bicycle.dart';
import '../../models/bike_type.dart';
import '../../models/rental_request.dart';
import '../../models/event.dart';
import '../events/event_registrations_screen.dart';
import '../../data/bike_data.dart';

class DashboardHomeScreen extends StatefulWidget {
  final Map<String, int> stats;
  final VoidCallback onRefresh;
  final Function(int)? onNavigateToTab;

  const DashboardHomeScreen({
    super.key,
    required this.stats,
    required this.onRefresh,
    this.onNavigateToTab,
  });

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  List<Bicycle> _bicycles = [];
  List<RentalRequest> _rentalRequests = [];
  List<Event> _events = [];
  int _pendingEventRegistrations = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data
      _bicycles = BikeData.getAllBikes();
      _rentalRequests = [
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
      ];

      _events = [
        Event(
          id: '1',
          name: 'Mountain Bike Rally',
          title: 'Mountain Bike Rally',
          description: 'Join us for an exciting mountain bike rally',
          date: DateTime.now().add(const Duration(days: 7)),
          eventTime: DateTime.now().add(const Duration(days: 7)),
          location: 'Mountain Trail Park',
          maxParticipants: 50,
          maxHeadCount: 50,
          difficulty: 'Intermediate',
          price: 25.0,
          imageUrl: 'https://example.com/mountain_rally.jpg',
          eligibilityCriteria: 'Age 16+, Basic cycling experience required',
          availableDates: [
            DateTime.now().add(const Duration(days: 7)).toString(),
            DateTime.now().add(const Duration(days: 14)).toString(),
          ],
          durationHours: 4,
          features: [
            'Scenic trails',
            'Professional guides',
            'Safety equipment included',
          ],
        ),
      ];

      _pendingEventRegistrations = 2;
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEventRegistrations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventRegistrationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building DashboardHomeScreen with stats: ${widget.stats}');

    final availableBikes = _bicycles.where((b) => b.isAvailable).length;
    final rentedBikes = _bicycles.where((b) => !b.isAvailable).length;
    final pendingRequests =
        _rentalRequests.where((r) => r.status == RentalStatus.pending).length;
    final activeRentals =
        _rentalRequests.where((r) => r.status == RentalStatus.active).length;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      widget.onRefresh();
                      await _loadDashboardData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Section
                            _buildWelcomeSection(),
                            const SizedBox(height: 16),

                            // Statistics Cards
                            SizedBox(
                              height: 180, // Fixed height for the grid
                              child: _buildStatsGrid(
                                availableBikes,
                                activeRentals,
                                pendingRequests,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Inventory Status
                            _buildInventoryStatus(),
                            const SizedBox(height: 16),

                            // Recent Bookings
                            _buildRecentBookings(),
                            const SizedBox(height: 16),

                            // Quick Actions
                            _buildQuickActions(),
                            const SizedBox(height: 16),

                            // Upcoming Events
                            if (_events.isNotEmpty) _buildUpcomingEvents(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_bicycles.length} bikes in inventory',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.directions_bike, size: 50, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int availableBikes,
    int activeRentals,
    int pendingRequests,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildStatCard(
          'Total Bikes',
          '${_bicycles.length}',
          Icons.directions_bike,
          AppColors.primary,
        ),
        _buildStatCard(
          'Available',
          '$availableBikes',
          Icons.check_circle,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInventoryStatusItem(
            'Mountain Bikes',
            _bicycles.where((b) => b.type == BikeType.mountain).length,
          ),
          const SizedBox(height: 8),
          _buildInventoryStatusItem(
            'Road Bikes',
            _bicycles.where((b) => b.type == BikeType.road).length,
          ),
          const SizedBox(height: 8),
          _buildInventoryStatusItem(
            'Electric Bikes',
            _bicycles.where((b) => b.type == BikeType.electric).length,
          ),
          const SizedBox(height: 8),
          _buildInventoryStatusItem(
            'Hybrid Bikes',
            _bicycles.where((b) => b.type == BikeType.hybrid).length,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatusItem(String type, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: count > 0 ? AppColors.success : AppColors.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            type,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
        Text(
          '$count available',
          style: TextStyle(
            color: count > 0 ? AppColors.success : AppColors.danger,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Bookings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab?.call(2),
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_rentalRequests.isEmpty)
            _buildEmptyState('No recent bookings', Icons.bookmark_border)
          else
            ..._rentalRequests.take(2).map(_buildBookingCard),
        ],
      ),
    );
  }

  Widget _buildBookingCard(RentalRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(request.status),
              color: _getStatusColor(request.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${request.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              request.statusDisplayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(request.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Add New Bicycle',
            Icons.add,
            AppColors.primary,
            () => widget.onNavigateToTab?.call(1),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            'Manage Rentals',
            Icons.receipt,
            AppColors.info,
            () => widget.onNavigateToTab?.call(2),
          ),
          const SizedBox(height: 8),
          if (_pendingEventRegistrations > 0)
            _buildQuickActionButton(
              'Event Registrations ($_pendingEventRegistrations)',
              Icons.event_note,
              AppColors.warning,
              _navigateToEventRegistrations,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab?.call(4),
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._events.take(1).map(_buildEventCard),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.formattedDate,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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

  IconData _getStatusIcon(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return Icons.pending;
      case RentalStatus.approved:
        return Icons.check_circle;
      case RentalStatus.active:
        return Icons.directions_bike;
      case RentalStatus.completed:
        return Icons.assignment_turned_in;
      case RentalStatus.rejected:
        return Icons.cancel;
    }
  }
}
