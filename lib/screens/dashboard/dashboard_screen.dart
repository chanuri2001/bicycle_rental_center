import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'dashboard_home_screen.dart';
import '../inventory/inventory_screen.dart';
import '../bookings/bookings_screen.dart';
import '../events/events_screen.dart';
import '../admin/admin_screen.dart';
import '../inventory/bicycle_availability_screen.dart';
import '../events/cycling_activities_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, int> _stats = {
    'total': 0,
    'available': 0,
    'inUse': 0,
    'pending': 0,
  };
  bool _showPanel = false;

  @override
  void initState() {
    super.initState();
    _stats = {'total': 0, 'available': 0, 'inUse': 0, 'pending': 0};
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _stats = {'total': 24, 'available': 18, 'inUse': 6, 'pending': 3};
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _stats = {'total': 24, 'available': 18, 'inUse': 6, 'pending': 3};
        });
      }
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
      _showPanel = false;
    });
  }

  List<Widget> get _screens => [
    DashboardHomeScreen(
      stats: _stats,
      onRefresh: _loadStats,
      onNavigateToTab: _navigateToTab,
    ),
    const InventoryScreen(),
    const BookingsScreen(),
    const BicycleAvailabilityScreen(),
    const EventsScreen(),
    const CyclingActivitiesScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => setState(() => _showPanel = true),
        ),
        title: const Text(
          'Bicycle Rental System',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main Content
          _screens[_currentIndex],

          // Navigation Panel Overlay
          if (_showPanel)
            GestureDetector(
              onTap: () => setState(() => _showPanel = false),
              child: Container(color: Colors.black54),
            ),

          // Navigation Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _showPanel ? 0 : -280,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 16,
              child: Container(
                width: 280,
                color: AppColors.darkCardBackground,
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bike Rental',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.primary,
                            ),
                            onPressed: () => setState(() => _showPanel = false),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),

                    // Navigation Items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildNavItem(
                            index: 0,
                            icon: Icons.home,
                            label: 'Dashboard',
                          ),
                          _buildNavItem(
                            index: 1,
                            icon: Icons.directions_bike,
                            label: 'Inventory',
                          ),
                          _buildNavItem(
                            index: 2,
                            icon: Icons.assignment,
                            label: 'Bookings',
                          ),
                          _buildNavItem(
                            index: 3,
                            icon: Icons.pedal_bike,
                            label: 'Bicycles',
                          ),
                          _buildNavItem(
                            index: 4,
                            icon: Icons.event,
                            label: 'Events',
                          ),
                          _buildNavItem(
                            index: 5,
                            icon: Icons.inventory_2,
                            label: 'Events Inventory',
                          ),
                          _buildNavItem(
                            index: 6,
                            icon: Icons.admin_panel_settings,
                            label: 'Admin',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => _navigateToTab(index),
    );
  }
}
