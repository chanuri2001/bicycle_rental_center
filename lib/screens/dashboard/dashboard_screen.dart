import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';
import '../../main.dart';
import 'dashboard_home_screen.dart';
import '../inventory/inventory_screen.dart';
import '../bookings/bookings_screen.dart';
import '../events/events_screen.dart';
import '../admin/admin_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Mock data for demo - replace with actual Supabase calls when ready
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _stats = {
            'total': 24,
            'available': 18,
            'inUse': 6,
            'pending': 3,
          };
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      // Set default values if error occurs
      if (mounted) {
        setState(() {
          _stats = {
            'total': 24,
            'available': 18,
            'inUse': 6,
            'pending': 3,
          };
        });
      }
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
        DashboardHomeScreen(
          stats: _stats,
          onRefresh: _loadStats,
          onNavigateToTab: _navigateToTab, // Pass the callback
        ),
        const InventoryScreen(),
        const BookingsScreen(),
        const EventsScreen(),
        const AdminScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
