import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../models/event_registration.dart';
import '../../models/event.dart';

class EventRegistrationsScreen extends StatefulWidget {
  const EventRegistrationsScreen({super.key});

  @override
  State<EventRegistrationsScreen> createState() => _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<EventRegistration> _allRegistrations = [];
  List<Event> _events = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  // Filter options for pending registrations
  DateTime? _filterSubmissionStartDate;
  DateTime? _filterSubmissionEndDate;
  DateTime? _filterEventStartDate;
  DateTime? _filterEventEndDate;
  String? _selectedEventFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // Mock events data
    _events = [
      Event(
        id: '1',
        name: 'Mountain Bike Rally',
        title: 'Mountain Bike Rally',
        description: 'Join us for an exciting mountain bike rally through scenic trails',
        date: DateTime.now().add(const Duration(days: 7)),
        eventTime: DateTime.now().add(const Duration(days: 7)),
        location: 'Mountain Trail Park',
        maxParticipants: 50,
        maxHeadCount: 50,
        
        imageUrl: 'https://example.com/rally.jpg',
        eligibilityCriteria: 'Age 16+, Basic cycling experience required',
        durationHours: 4,
        features: ['Scenic trails', 'Professional guides', 'Safety equipment included'],
      ),
      Event(
        id: '2',
        name: 'City Cycling Tour',
        title: 'City Cycling Tour',
        description: 'Explore the city on two wheels with our guided tour',
        date: DateTime.now().add(const Duration(days: 14)),
        eventTime: DateTime.now().add(const Duration(days: 14)),
        location: 'Downtown City Center',
        maxParticipants: 30,
        maxHeadCount: 30,
        
        imageUrl: 'https://example.com/city-tour.jpg',
        eligibilityCriteria: 'Age 12+, No experience required',
        durationHours: 2,
        features: ['City landmarks', 'Photo stops', 'Local guide'],
      ),
    ];

    // Mock registrations data
    _allRegistrations = [
      EventRegistration(
        id: '1',
        eventId: '1',
        participantName: 'John Doe',
        participantEmail: 'john@example.com',
        participantPhone: '+1234567890',
        age: 25,
        emergencyContact: 'Jane Doe',
        emergencyPhone: '+1234567891',
        medicalConditions: 'None',
        experienceLevel: 'Intermediate',
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: EventRegistrationStatus.pending,
      ),
      EventRegistration(
        id: '2',
        eventId: '1',
        participantName: 'Alice Smith',
        participantEmail: 'alice@example.com',
        participantPhone: '+1234567892',
        age: 30,
        emergencyContact: 'Bob Smith',
        emergencyPhone: '+1234567893',
        medicalConditions: 'Asthma',
        experienceLevel: 'Advanced',
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: EventRegistrationStatus.approved,
        approvalDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      EventRegistration(
        id: '3',
        eventId: '2',
        participantName: 'Mike Johnson',
        participantEmail: 'mike@example.com',
        participantPhone: '+1234567894',
        age: 22,
        emergencyContact: 'Sarah Johnson',
        emergencyPhone: '+1234567895',
        medicalConditions: 'None',
        experienceLevel: 'Beginner',
        submissionDate: DateTime.now().subtract(const Duration(hours: 6)),
        status: EventRegistrationStatus.confirmed,
        confirmationDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      EventRegistration(
        id: '4',
        eventId: '1',
        participantName: 'Emma Wilson',
        participantEmail: 'emma@example.com',
        participantPhone: '+1234567896',
        age: 28,
        emergencyContact: 'Tom Wilson',
        emergencyPhone: '+1234567897',
        medicalConditions: 'None',
        experienceLevel: 'Intermediate',
        submissionDate: DateTime.now().subtract(const Duration(days: 3)),
        status: EventRegistrationStatus.completed,
        completionDate: DateTime.now().subtract(const Duration(hours: 1)),
        hasAttended: true,
      ),
      EventRegistration(
        id: '5',
        eventId: '2',
        participantName: 'David Brown',
        participantEmail: 'david@example.com',
        participantPhone: '+1234567898',
        age: 35,
        emergencyContact: 'Lisa Brown',
        emergencyPhone: '+1234567899',
        medicalConditions: 'Back problems',
        experienceLevel: 'Beginner',
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: EventRegistrationStatus.rejected,
        rejectionReason: 'Medical condition not suitable for this event',
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<EventRegistration> get _filteredRegistrations {
    List<EventRegistration> filtered = _allRegistrations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((registration) =>
          registration.participantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          registration.participantEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          registration.participantPhone.contains(_searchQuery)).toList();
    }

    return filtered;
  }

  List<EventRegistration> _getRegistrationsByStatus(EventRegistrationStatus? status) {
    if (status == null) return _filteredRegistrations;
    
    List<EventRegistration> filtered = _filteredRegistrations
        .where((registration) => registration.status == status)
        .toList();

    // Apply additional filters for pending registrations
    if (status == EventRegistrationStatus.pending) {
      if (_filterSubmissionStartDate != null) {
        filtered = filtered.where((r) => 
            r.submissionDate.isAfter(_filterSubmissionStartDate!) ||
            r.submissionDate.isAtSameMomentAs(_filterSubmissionStartDate!)).toList();
      }
      
      if (_filterSubmissionEndDate != null) {
        filtered = filtered.where((r) => 
            r.submissionDate.isBefore(_filterSubmissionEndDate!.add(const Duration(days: 1)))).toList();
      }

      if (_selectedEventFilter != null) {
        filtered = filtered.where((r) => r.eventId == _selectedEventFilter).toList();
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Event Registrations',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadRegistrations,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'All (${_getRegistrationsByStatus(null).length})'),
            Tab(text: 'Pending (${_getRegistrationsByStatus(EventRegistrationStatus.pending).length})'),
            Tab(text: 'Approved (${_getRegistrationsByStatus(EventRegistrationStatus.approved).length})'),
            Tab(text: 'Confirmed (${_getRegistrationsByStatus(EventRegistrationStatus.confirmed).length})'),
            Tab(text: 'Completed (${_getRegistrationsByStatus(EventRegistrationStatus.completed).length})'),
            Tab(text: 'Rejected (${_getRegistrationsByStatus(EventRegistrationStatus.rejected).length})'),
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
                hintText: 'Search registrations...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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

          // Filter Section for Pending Tab
          if (_tabController.index == 1) _buildFilterSection(),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRegistrationsList(_getRegistrationsByStatus(null)),
                      _buildRegistrationsList(_getRegistrationsByStatus(EventRegistrationStatus.pending)),
                      _buildRegistrationsList(_getRegistrationsByStatus(EventRegistrationStatus.approved)),
                      _buildRegistrationsList(_getRegistrationsByStatus(EventRegistrationStatus.confirmed)),
                      _buildRegistrationsList(_getRegistrationsByStatus(EventRegistrationStatus.completed)),
                      _buildRegistrationsList(_getRegistrationsByStatus(EventRegistrationStatus.rejected)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Submission Date',
                  _filterSubmissionStartDate != null || _filterSubmissionEndDate != null,
                  () => _showSubmissionDateFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Event',
                  _selectedEventFilter != null,
                  () => _showEventFilter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.2) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationsList(List<EventRegistration> registrations) {
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No registrations match your search'
                  : 'No registrations found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registrations.length,
        itemBuilder: (context, index) {
          final registration = registrations[index];
          return _buildRegistrationCard(registration);
        },
      ),
    );
  }

  Widget _buildRegistrationCard(EventRegistration registration) {
    final event = _events.firstWhere(
      (e) => e.id == registration.eventId,
      orElse: () => Event(
        id: '',
        name: 'Unknown Event',
        title: 'Unknown Event',
        description: '',
        date: DateTime.now(),
        eventTime: DateTime.now(),
        location: '',
        maxParticipants: 0,
        maxHeadCount: 0,
        
        eligibilityCriteria: '',
        durationHours: 0,
        features: [],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with participant info and status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(registration.status).withOpacity(0.2),
                  child: Text(
                    registration.participantName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(registration.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registration.participantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${registration.age} • ${registration.experienceLevel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(registration.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    registration.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(registration.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Registration details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email, registration.participantEmail),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.phone, registration.participantPhone),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.contact_emergency, 
                    '${registration.emergencyContact} (${registration.emergencyPhone})'),
                if (registration.medicalConditions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.medical_services, registration.medicalConditions),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 
                    'Submitted: ${registration.formattedSubmissionDate}'),
              ],
            ),
          ),

          // Action buttons based on status
          if (registration.status == EventRegistrationStatus.pending)
            _buildPendingActions(registration)
          else if (registration.status == EventRegistrationStatus.approved)
            _buildApprovedActions(registration)
          else if (registration.status == EventRegistrationStatus.confirmed)
            _buildConfirmedActions(registration),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approveRegistration(registration),
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
              onPressed: () => _rejectRegistration(registration),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _confirmParticipation(registration),
          icon: const Icon(Icons.how_to_reg, size: 16),
          label: const Text('Confirm Participation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmedActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _markAsCompleted(registration),
          icon: const Icon(Icons.done_all, size: 16),
          label: const Text('Mark as Completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _approveRegistration(EventRegistration registration) {
    setState(() {
      final index = _allRegistrations.indexWhere((r) => r.id == registration.id);
      if (index != -1) {
        _allRegistrations[index] = registration.copyWith(
          status: EventRegistrationStatus.approved,
          approvalDate: DateTime.now(),
        );
      }
    });
    _showSnackBar('Registration approved successfully!', AppColors.success);
  }

  void _rejectRegistration(EventRegistration registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Reject Registration',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for rejection:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rejection reason...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store the rejection reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _allRegistrations.indexWhere((r) => r.id == registration.id);
                if (index != -1) {
                  _allRegistrations[index] = registration.copyWith(
                    status: EventRegistrationStatus.rejected,
                    rejectionReason: 'Registration rejected by admin',
                  );
                }
              });
              _showSnackBar('Registration rejected', AppColors.danger);
            },
            child: const Text('Reject', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmParticipation(EventRegistration registration) {
    setState(() {
      final index = _allRegistrations.indexWhere((r) => r.id == registration.id);
      if (index != -1) {
        _allRegistrations[index] = registration.copyWith(
          status: EventRegistrationStatus.confirmed,
          confirmationDate: DateTime.now(),
        );
      }
    });
    _showSnackBar('Participation confirmed!', AppColors.primary);
  }

  void _markAsCompleted(EventRegistration registration) {
    setState(() {
      final index = _allRegistrations.indexWhere((r) => r.id == registration.id);
      if (index != -1) {
        _allRegistrations[index] = registration.copyWith(
          status: EventRegistrationStatus.completed,
          completionDate: DateTime.now(),
          hasAttended: true,
        );
      }
    });
    _showSnackBar('Registration marked as completed!', AppColors.info);
  }

  void _showSubmissionDateFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Filter by Submission Date',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(
                _filterSubmissionStartDate?.toString().split(' ')[0] ?? 'Not selected',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _filterSubmissionStartDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _filterSubmissionStartDate = date;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('End Date', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(
                _filterSubmissionEndDate?.toString().split(' ')[0] ?? 'Not selected',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _filterSubmissionEndDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _filterSubmissionEndDate = date;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showEventFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Filter by Event',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Events', style: TextStyle(color: AppColors.textPrimary)),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedEventFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedEventFilter = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
            ..._events.map((event) => ListTile(
              title: Text(event.title, style: const TextStyle(color: AppColors.textPrimary)),
              leading: Radio<String>(
                value: event.id,
                groupValue: _selectedEventFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedEventFilter = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filterSubmissionStartDate = null;
      _filterSubmissionEndDate = null;
      _filterEventStartDate = null;
      _filterEventEndDate = null;
      _selectedEventFilter = null;
    });
  }

  Color _getStatusColor(EventRegistrationStatus status) {
    switch (status) {
      case EventRegistrationStatus.pending:
        return AppColors.warning;
      case EventRegistrationStatus.approved:
        return AppColors.success;
      case EventRegistrationStatus.rejected:
        return AppColors.danger;
      case EventRegistrationStatus.confirmed:
        return AppColors.primary;
      case EventRegistrationStatus.completed:
        return AppColors.info;
      case EventRegistrationStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}