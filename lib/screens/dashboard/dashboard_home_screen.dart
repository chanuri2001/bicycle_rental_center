import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/bicycle.dart';
import '../../models/rental_request.dart';
import '../../models/event.dart';
import '../events/event_registrations_screen.dart';

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
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for bicycles
    _bicycles = [
      Bicycle(
        id: '1',
        name: 'Mountain Explorer',
        type: 'Mountain',
        isAvailable: true,
        pricePerHour: 15.0,
        description: 'Perfect for mountain trails',
        imageUrl:
            'https://images.unsplash.com/photo-1544191696-15693072e0b5?w=400',
      ),
      Bicycle(
        id: '2',
        name: 'City Cruiser',
        type: 'City',
        isAvailable: false,
        pricePerHour: 10.0,
        description: 'Comfortable city riding',
        imageUrl:
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
      ),
      Bicycle(
        id: '3',
        name: 'Speed Demon',
        type: 'Road',
        isAvailable: true,
        pricePerHour: 20.0,
        description: 'High-speed road cycling',
        imageUrl:
            'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      ),
    ];

    // Mock data for rental requests using the new model
    _rentalRequests = [
      RentalRequest(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        userPhone: '+1234567890',
        bicycleId: '2',
        bicycleName: 'City Cruiser',
        bicycleModel: 'Giant Escape',
        submissionDate: DateTime.now().subtract(const Duration(hours: 3)),
        startDate: DateTime.now().subtract(const Duration(hours: 2)),
        endDate: DateTime.now().add(const Duration(hours: 4)),
        durationDays: 1,
        totalCost: 60.0,
        status: RentalStatus.active,
        pickupDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
        activeTime: const Duration(hours: 2),
      ),
      RentalRequest(
        id: '2',
        userId: 'user2',
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        userPhone: '+1234567891',
        bicycleId: '1',
        bicycleName: 'Mountain Explorer',
        bicycleModel: 'Trek X-Caliber',
        submissionDate: DateTime.now().subtract(const Duration(hours: 1)),
        startDate: DateTime.now().add(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 5)),
        durationDays: 1,
        totalCost: 60.0,
        status: RentalStatus.pending,
        notes: 'Need for weekend trip',
      ),
      RentalRequest(
        id: '3',
        userId: 'user3',
        userName: 'Mike Johnson',
        userEmail: 'mike@example.com',
        userPhone: '+1234567892',
        bicycleId: '3',
        bicycleName: 'Speed Demon',
        bicycleModel: 'Specialized Allez',
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
        durationDays: 1,
        totalCost: 40.0,
        status: RentalStatus.approved,
        approvalDate: DateTime.now().subtract(const Duration(hours: 2)),
        approvedBy: 'Admin',
      ),
    ];

    // Mock data for events
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
        
        imageUrl:
            'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        eligibilityCriteria: 'Age 16+, Basic cycling experience required',
        durationHours: 4,
        features: [
          'Scenic trails',
          'Professional guides',
          'Safety equipment included',
        ],
      ),
      Event(
        id: '2',
        name: 'City Cycling Tour',
        title: 'City Cycling Tour',
        description: 'Explore the city on two wheels',
        date: DateTime.now().add(const Duration(days: 3)),
        eventTime: DateTime.now().add(const Duration(days: 3)),
        location: 'Downtown City Center',
        maxParticipants: 30,
        maxHeadCount: 30,
        
        imageUrl:
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
        eligibilityCriteria: 'Age 12+, No experience required',
        durationHours: 2,
        features: ['City landmarks', 'Photo stops', 'Local guide'],
      ),
    ];

    // Mock pending event registrations count
    _pendingEventRegistrations = 12; // This would come from your actual data

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToEventRegistrations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventRegistrationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_bike, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Bicycle Manager',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              widget.onRefresh();
              _loadDashboardData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () async {
                widget.onRefresh();
                await _loadDashboardData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage your bicycle rental center',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.directions_bike,
                            size: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          'Total Bicycles',
                          '${widget.stats['total'] ?? 0}',
                          Icons.directions_bike,
                          AppColors.primary,
                        ),
                        _buildStatCard(
                          'Available',
                          '${widget.stats['available'] ?? 0}',
                          Icons.check_circle,
                          AppColors.success,
                        ),
                        _buildStatCard(
                          'Active Rentals',
                          '${_rentalRequests.where((r) => r.status == RentalStatus.active).length}',
                          Icons.access_time,
                          AppColors.warning,
                        ),
                        _buildStatCard(
                          'Pending Requests',
                          '${_rentalRequests.where((r) => r.status == RentalStatus.pending).length}',
                          Icons.pending,
                          AppColors.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Event Registrations Alert Card
                    if (_pendingEventRegistrations > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.event_note,
                                color: AppColors.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Event Registrations',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_pendingEventRegistrations registrations need your attention',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _navigateToEventRegistrations,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Review',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Recent Bookings Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Bookings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onNavigateToTab?.call(2);
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Recent bookings list
                    if (_rentalRequests.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No recent bookings',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._rentalRequests
                          .take(3)
                          .map((request) => _buildBookingCard(request)),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickActionButton(
                            context,
                            'Add New Bicycle',
                            Icons.add,
                            AppColors.primary,
                            () {
                              widget.onNavigateToTab?.call(1);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildQuickActionButton(
                            context,
                            'View Bicycles',
                            Icons.add,
                            AppColors.primary,
                            () {
                              widget.onNavigateToTab?.call(1);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickActionButton(
                            context,
                            'View Pending Bookings',
                            Icons.visibility,
                            AppColors.warning,
                            () {
                              widget.onNavigateToTab?.call(2);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickActionButton(
                            context,
                            'View Pending Events',
                            Icons.event_note,
                            AppColors.info,
                            _navigateToEventRegistrations,
                          ),
                          const SizedBox(height: 12),
                          _buildQuickActionButton(
                            context,
                            'Manage Events',
                            Icons.event,
                            AppColors.secondary,
                            () {
                              widget.onNavigateToTab?.call(3);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Events
                    if (_events.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onNavigateToTab?.call(3);
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._events
                          .take(2)
                          .map((event) => _buildEventCard(event)),
                    ],

                    const SizedBox(height: 24),

                    // System Status
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusItem('Database', true),
                          const SizedBox(height: 8),
                          _buildStatusItem('Payment System', true),
                          const SizedBox(height: 8),
                          _buildStatusItem('Notification Service', true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(RentalRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(request.status),
              color: _getStatusColor(request.status),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.bicycleName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${request.totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (request.status == RentalStatus.active &&
                        request.activeTime != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${request.formattedActiveTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(request.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.maxParticipants} participants',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                daysUntil == 0
                    ? 'Today'
                    : daysUntil == 1
                        ? 'Tomorrow'
                        : '${daysUntil}d',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                event.formattedDate,
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

  Widget _buildStatusItem(String service, bool isOnline) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          service,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: isOnline ? AppColors.success : AppColors.danger,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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