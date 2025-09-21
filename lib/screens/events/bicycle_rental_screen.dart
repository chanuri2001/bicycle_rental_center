import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enhanced Bike model with validation and better structure
class Bike {
  final String id;
  final String makeName;
  final String modelName;
  final String qrCode;
  final String? renterName;
  final DateTime? rentalStartDate;
  final Color statusColor;
  final String imageUrl;

  Bike({
    required this.id,
    required this.makeName,
    required this.modelName,
    required this.qrCode,
    this.renterName,
    this.rentalStartDate,
    this.statusColor = const Color(0xFF4CAF50),
    this.imageUrl = '',
  });

  String get fullName => '$makeName $modelName';

  String get rentalDuration {
    if (rentalStartDate == null) return 'N/A';
    final duration = DateTime.now().difference(rentalStartDate!);
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    }
    return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
  }
}

// Custom theme and constants
class AppTheme {
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color surfaceColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF21262D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF4CAF50);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
  );
}

// Main screen with enhanced UI and architecture
class RentedBicyclesScreen extends StatefulWidget {
  final String centerActivityUuid;

  const RentedBicyclesScreen({super.key, required this.centerActivityUuid});

  @override
  State<RentedBicyclesScreen> createState() => _RentedBicyclesScreenState();
}

class _RentedBicyclesScreenState extends State<RentedBicyclesScreen>
    with TickerProviderStateMixin {
  List<Bike> rentedBikes = [];
  bool isLoading = false;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadBikeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBikeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      final bikes = [
        Bike(
          id: 'bike_001',
          makeName: 'Trek',
          modelName: 'FX 2 Disc',
          qrCode: 'TRK-FX2-2024-001',
          renterName: 'John Doe',
          rentalStartDate: DateTime.now().subtract(
            const Duration(days: 2, hours: 3),
          ),
          statusColor: AppTheme.successColor,
        ),
        Bike(
          id: 'bike_002',
          makeName: 'Giant',
          modelName: 'Escape 3',
          qrCode: 'GNT-ESC-2024-002',
          renterName: 'Jane Smith',
          rentalStartDate: DateTime.now().subtract(
            const Duration(days: 1, hours: 8),
          ),
          statusColor: AppTheme.secondaryColor,
        ),
        Bike(
          id: 'bike_003',
          makeName: 'Specialized',
          modelName: 'Sirrus X 3.0',
          qrCode: 'SPC-SRX-2024-003',
          renterName: 'Mike Johnson',
          rentalStartDate: DateTime.now().subtract(
            const Duration(hours: 6, minutes: 30),
          ),
          statusColor: AppTheme.primaryColor,
        ),
        Bike(
          id: 'bike_004',
          makeName: 'Cannondale',
          modelName: 'Quick CX 3',
          qrCode: 'CND-QCX-2024-004',
          renterName: 'Sarah Wilson',
          rentalStartDate: DateTime.now().subtract(const Duration(minutes: 45)),
          statusColor: AppTheme.successColor,
        ),
      ];

      setState(() {
        rentedBikes = bikes;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load bike data. Please try again.';
        isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bike,
                  size: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Rentals',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${rentedBikes.length} bikes currently rented',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBikeCard(BuildContext context, Bike bike, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.3 + (index * 0.1)),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: InkWell(
              onTap: () => _navigateToBikeDetails(context, bike),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'bike_${bike.id}',
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  bike.statusColor,
                                  bike.statusColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.directions_bike,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bike.fullName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    size: 16,
                                    color: bike.statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    bike.qrCode,
                                    style: TextStyle(
                                      color: bike.statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                            color: bike.statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bike.rentalDuration,
                            style: TextStyle(
                              color: bike.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rented by: ${bike.renterName ?? 'Unknown'}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (bike.rentalStartDate != null)
                            Text(
                              DateFormat(
                                'MMM dd, HH:mm',
                              ).format(bike.rentalStartDate!),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBikeDetails(BuildContext context, Bike bike) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                BikeDetailsScreen(bike: bike),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.directions_bike_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Rentals',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All bikes are currently available',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            errorMessage ?? 'Something went wrong',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadBikeData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rental Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: isLoading ? null : _loadBikeData,
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body:
            isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading rental data...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                : errorMessage != null
                ? _buildErrorState()
                : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child:
                          rentedBikes.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                onRefresh: _loadBikeData,
                                color: AppTheme.primaryColor,
                                backgroundColor: AppTheme.surfaceColor,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: rentedBikes.length,
                                  itemBuilder: (context, index) {
                                    return _buildBikeCard(
                                      context,
                                      rentedBikes[index],
                                      index,
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}

// Enhanced details screen
class BikeDetailsScreen extends StatefulWidget {
  final Bike bike;

  const BikeDetailsScreen({super.key, required this.bike});

  @override
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: widget.bike.statusColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.bike.fullName),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Add menu options
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Hero bike card
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'bike_${widget.bike.id}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.bike.statusColor,
                                  widget.bike.statusColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.directions_bike,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.bike.fullName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Currently Rented',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rental Information
              _buildDetailCard('Rental Information', [
                _buildDetailRow(
                  Icons.person_outline,
                  'Renter',
                  widget.bike.renterName ?? 'Unknown',
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Duration',
                  widget.bike.rentalDuration,
                  valueColor: widget.bike.statusColor,
                ),
                if (widget.bike.rentalStartDate != null)
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Started',
                    DateFormat(
                      'MMM dd, yyyy - hh:mm a',
                    ).format(widget.bike.rentalStartDate!),
                  ),
              ]),

              // Bike Details
              _buildDetailCard('Bike Details', [
                _buildDetailRow(Icons.business, 'Make', widget.bike.makeName),
                _buildDetailRow(
                  Icons.directions_bike,
                  'Model',
                  widget.bike.modelName,
                ),
                _buildDetailRow(Icons.qr_code, 'QR Code', widget.bike.qrCode),
                _buildDetailRow(Icons.tag, 'Bike ID', widget.bike.id),
              ]),

              // Action Buttons
            ],
          ),
        ),
      ),
    );
  }
}
