import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../utils/constants.dart';
import '../../models/event_registration.dart';
import '../../models/event.dart';

class EventRegistrationsScreen extends StatefulWidget {
  const EventRegistrationsScreen({super.key});

  @override
  State<EventRegistrationsScreen> createState() =>
      _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<EventRegistration> _allRegistrations = [];
  List<Event> _events = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;

  // Filter options
  DateTime? _filterSubmissionStartDate;
  DateTime? _filterSubmissionEndDate;
  String? _selectedEventFilter;
  String? _selectedActivityTypeFilter;
  String? _selectedActivityStatusFilter;

  // API credentials
  final String _clientId = 'your_client_id';
  final String _clientSecret = 'your_client_secret';
  final String _baseUrl = 'http://spinisland.devtester.xyz';
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Metadata from API
  List<dynamic> activityTypes = [];
  List<dynamic> activityStatus = [];
  List<dynamic> activityTrackTypes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _authenticate();
      await Future.wait([_fetchFilterMetadata(), _loadRegistrations()]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
      _loadMockData(); // Fallback to mock data
    }
  }

  Future<void> _authenticate() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _accessToken = data['access_token'];
          _tokenExpiry = DateTime.now().add(
            Duration(seconds: data['expires_in'] ?? 3600),
          );
        });
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    if (_accessToken == null ||
        _tokenExpiry == null ||
        _tokenExpiry!.isBefore(DateTime.now())) {
      await _authenticate();
    }
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchFilterMetadata() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/activity/meta/filter-meta'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activityTypes = data['result']['activityTypes'] ?? [];
          activityStatus = data['result']['activityStatus'] ?? [];
          activityTrackTypes = data['result']['activityTrackTypes'] ?? [];
        });
      } else {
        throw Exception('Failed to load filter metadata');
      }
    } catch (e) {
      debugPrint('Error fetching filter metadata: $e');
      throw e;
    }
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await _getAuthHeaders();

      // Fetch events
      final eventsResponse = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/events'),
        headers: headers,
      );

      // Fetch registrations
      final registrationsResponse = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/registrations'),
        headers: headers,
      );

      if (eventsResponse.statusCode == 200 &&
          registrationsResponse.statusCode == 200) {
        final eventsData = json.decode(eventsResponse.body);
        final registrationsData = json.decode(registrationsResponse.body);

        setState(() {
          _events =
              (eventsData['result'] as List)
                  .map((e) => Event.fromJson(e))
                  .toList();

          _allRegistrations =
              (registrationsData['result'] as List)
                  .map((r) => EventRegistration.fromJson(r))
                  .toList();

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
      throw e;
    }
  }

  void _loadMockData() {
    // Mock events data
    _events = [
      Event(
        id: '1',
        name: 'Mountain Bike Rally',
        title: 'Mountain Bike Rally',
        description:
            'Join us for an exciting mountain bike rally through scenic trails',
        date: DateTime.now().add(const Duration(days: 7)),
        eventTime: DateTime.now().add(const Duration(days: 7)),
        location: 'Mountain Trail Park',
        maxParticipants: 50,
        maxHeadCount: 50,
        eligibilityCriteria: 'Age 16+, Basic cycling experience required',
        durationHours: 4,
        features: [
          'Scenic trails',
          'Professional guides',
          'Safety equipment included',
        ],
        difficulty: 'Intermediate',
        price: 49.99,
        imageUrl: 'https://example.com/rally.jpg',
        availableDates: [],
      ),
    ];

    // Mock registrations data with proper status values
    _allRegistrations = [
      EventRegistration(
        id: '1',
        eventId: '1',
        participantName: 'John Doe',
        participantEmail: 'john@example.com',
        participantPhone: '+1234567890',
        age: 25,
        count: 3,
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
        count: 4,
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
        eventId: '1',
        participantName: 'Mike Johnson',
        participantEmail: 'mike@example.com',
        participantPhone: '+1234567894',
        age: 22,
        count: 5,
        emergencyContact: 'Sarah Johnson',
        emergencyPhone: '+1234567895',
        medicalConditions: 'None',
        experienceLevel: 'Beginner',
        submissionDate: DateTime.now().subtract(const Duration(hours: 6)),
        status: EventRegistrationStatus.confirmed,
        confirmationDate: DateTime.now().subtract(const Duration(hours: 2)),
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
      filtered =
          filtered
              .where(
                (registration) =>
                    registration.participantName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    registration.participantEmail.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    registration.participantPhone.contains(_searchQuery),
              )
              .toList();
    }

    return filtered;
  }

  List<EventRegistration> _getRegistrationsByStatus(
    EventRegistrationStatus? status,
  ) {
    if (status == null) return _filteredRegistrations;

    List<EventRegistration> filtered =
        _filteredRegistrations
            .where((registration) => registration.status == status)
            .toList();

    // Apply additional filters for pending registrations
    if (status == EventRegistrationStatus.pending) {
      if (_filterSubmissionStartDate != null) {
        filtered =
            filtered
                .where(
                  (r) =>
                      r.submissionDate.isAfter(_filterSubmissionStartDate!) ||
                      r.submissionDate.isAtSameMomentAs(
                        _filterSubmissionStartDate!,
                      ),
                )
                .toList();
      }

      if (_filterSubmissionEndDate != null) {
        filtered =
            filtered
                .where(
                  (r) => r.submissionDate.isBefore(
                    _filterSubmissionEndDate!.add(const Duration(days: 1)),
                  ),
                )
                .toList();
      }

      if (_selectedEventFilter != null) {
        filtered =
            filtered.where((r) => r.eventId == _selectedEventFilter).toList();
      }

      if (_selectedActivityTypeFilter != null) {
        final eventIds =
            _events
                .where((e) => e.activityType == _selectedActivityTypeFilter)
                .map((e) => e.id)
                .toList();
        filtered = filtered.where((r) => eventIds.contains(r.eventId)).toList();
      }

      if (_selectedActivityStatusFilter != null) {
        final eventIds =
            _events
                .where((e) => e.activityStatus == _selectedActivityStatusFilter)
                .map((e) => e.id)
                .toList();
        filtered = filtered.where((r) => eventIds.contains(r.eventId)).toList();
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
            onPressed: _initializeData,
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
            Tab(
              text:
                  'Pending (${_getRegistrationsByStatus(EventRegistrationStatus.pending).length})',
            ),
            Tab(
              text:
                  'Approved (${_getRegistrationsByStatus(EventRegistrationStatus.approved).length})',
            ),
            Tab(
              text:
                  'Confirmed (${_getRegistrationsByStatus(EventRegistrationStatus.confirmed).length})',
            ),
            Tab(
              text:
                  'Completed (${_getRegistrationsByStatus(EventRegistrationStatus.completed).length})',
            ),
            Tab(
              text:
                  'Rejected (${_getRegistrationsByStatus(EventRegistrationStatus.rejected).length})',
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
                hintText: 'Search registrations...',
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

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),

          // Filter Section for Pending Tab
          if (_tabController.index == 1) _buildFilterSection(),

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
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(null),
                        ),
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(
                            EventRegistrationStatus.pending,
                          ),
                        ),
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(
                            EventRegistrationStatus.approved,
                          ),
                        ),
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(
                            EventRegistrationStatus.confirmed,
                          ),
                        ),
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(
                            EventRegistrationStatus.completed,
                          ),
                        ),
                        _buildRegistrationsList(
                          _getRegistrationsByStatus(
                            EventRegistrationStatus.rejected,
                          ),
                        ),
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
                  _filterSubmissionStartDate != null ||
                      _filterSubmissionEndDate != null,
                  () => _showSubmissionDateFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Event',
                  _selectedEventFilter != null,
                  () => _showEventFilter(),
                ),
                const SizedBox(width: 8),
                if (activityTypes.isNotEmpty)
                  _buildFilterChip(
                    'Activity Type',
                    _selectedActivityTypeFilter != null,
                    () => _showActivityTypeFilter(),
                  ),
                const SizedBox(width: 8),
                if (activityStatus.isNotEmpty)
                  _buildFilterChip(
                    'Activity Status',
                    _selectedActivityStatusFilter != null,
                    () => _showActivityStatusFilter(),
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
          color:
              isActive
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isActive
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
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
              Icon(Icons.check_circle, size: 14, color: AppColors.primary),
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
      orElse:
          () => Event(
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
            difficulty: '',
            price: 0,
            imageUrl: '',
            availableDates: [],
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
                  backgroundColor: _getStatusColor(
                    registration.status,
                  ).withOpacity(0.2),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      registration.status,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    registration.activityStatus,
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
                _buildInfoRow(
                  Icons.contact_emergency,
                  '${registration.emergencyContact} (${registration.emergencyPhone})',
                ),
                if (registration.medicalConditions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.medical_services,
                    registration.medicalConditions,
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'Submitted: ${DateFormat('MMM dd, yyyy hh:mm a').format(registration.submissionDate)}',
                ),
                if (registration.status.index >
                    EventRegistrationStatus.pending.index) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    _getStatusIcon(registration.status),
                    '${registration.activityStatus}: ${_getStatusDateText(registration)}',
                  ),
                ],
                if (registration.status == EventRegistrationStatus.rejected &&
                    registration.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.info, registration.rejectionReason!),
                ],
              ],
            ),
          ),

          // Event details section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildEventDetailChip(
                        Icons.calendar_today,
                        DateFormat('MMM dd, yyyy').format(event.date),
                      ),
                      const SizedBox(width: 8),
                      _buildEventDetailChip(
                        Icons.access_time,
                        DateFormat('hh:mm a').format(event.eventTime),
                      ),
                      const SizedBox(width: 8),
                      _buildEventDetailChip(
                        Icons.timer,
                        '${event.durationHours} hrs',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildEventDetailChip(Icons.location_on, event.location),
                  const SizedBox(height: 8),
                  if (event.features.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          event.features
                              .take(3)
                              .map(
                                (feature) => Chip(
                                  label: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  backgroundColor: AppColors.cardBackground,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                    ),
                ],
              ),
            ),
          ),

          // Action buttons based on status
          if (registration.status == EventRegistrationStatus.pending)
            _buildPendingActions(registration)
          else if (registration.status == EventRegistrationStatus.approved)
            _buildApprovedActions(registration)
          else if (registration.status == EventRegistrationStatus.confirmed)
            _buildConfirmedActions(registration)
          else if (registration.status == EventRegistrationStatus.completed)
            _buildCompletedActions(registration)
          else if (registration.status == EventRegistrationStatus.rejected)
            _buildRejectedActions(registration),

          // More options button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editRegistration(registration);
                    } else if (value == 'delete') {
                      _deleteRegistration(registration);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit Registration'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete Registration'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmParticipation(registration),
              icon: const Icon(Icons.how_to_reg, size: 16),
              label: const Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsCompleted(registration),
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editRegistration(registration),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _cancelRegistration(registration),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedActions(EventRegistration registration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editRegistration(registration),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _cancelRegistration(registration),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
            ),
          ),
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

  Widget _buildEventDetailChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.cardBackground,
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _getStatusIcon(EventRegistrationStatus status) {
    switch (status) {
      case EventRegistrationStatus.approved:
        return Icons.check_circle;
      case EventRegistrationStatus.confirmed:
        return Icons.how_to_reg;
      case EventRegistrationStatus.completed:
        return Icons.done_all;
      case EventRegistrationStatus.rejected:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusDateText(EventRegistration registration) {
    switch (registration.status) {
      case EventRegistrationStatus.approved:
        return DateFormat(
          'MMM dd, yyyy hh:mm a',
        ).format(registration.approvalDate!);
      case EventRegistrationStatus.confirmed:
        return DateFormat(
          'MMM dd, yyyy hh:mm a',
        ).format(registration.confirmationDate!);
      case EventRegistrationStatus.completed:
        return DateFormat(
          'MMM dd, yyyy hh:mm a',
        ).format(registration.completionDate!);
      default:
        return '';
    }
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

  void _approveRegistration(EventRegistration registration) {
    setState(() {
      final index = _allRegistrations.indexWhere(
        (r) => r.id == registration.id,
      );
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
      builder:
          (context) => AlertDialog(
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
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    final index = _allRegistrations.indexWhere(
                      (r) => r.id == registration.id,
                    );
                    if (index != -1) {
                      _allRegistrations[index] = registration.copyWith(
                        status: EventRegistrationStatus.rejected,
                        rejectionReason: 'Registration rejected by admin',
                      );
                    }
                  });
                  _showSnackBar('Registration rejected', AppColors.danger);
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

  void _confirmParticipation(EventRegistration registration) {
    setState(() {
      final index = _allRegistrations.indexWhere(
        (r) => r.id == registration.id,
      );
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
      final index = _allRegistrations.indexWhere(
        (r) => r.id == registration.id,
      );
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

  void _editRegistration(EventRegistration registration) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Edit Registration',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(
                      text: registration.participantName,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Participant Name',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    onChanged: (value) {
                      // Update name logic
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(
                      text: registration.participantEmail,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    onChanged: (value) {
                      // Update email logic
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(
                      text: registration.participantPhone,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    onChanged: (value) {
                      // Update phone logic
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Event Date',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(
                        _events
                            .firstWhere((e) => e.id == registration.eventId)
                            .date,
                      ),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _events
                                .firstWhere((e) => e.id == registration.eventId)
                                .date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        // Update event date logic
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
                  // Save changes logic
                  Navigator.pop(context);
                  _showSnackBar(
                    'Registration updated successfully!',
                    AppColors.success,
                  );
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteRegistration(EventRegistration registration) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Delete Registration',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to delete registration for ${registration.participantName}?',
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
                  setState(() {
                    _allRegistrations.removeWhere(
                      (r) => r.id == registration.id,
                    );
                  });
                  Navigator.pop(context);
                  _showSnackBar('Registration deleted', AppColors.danger);
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

  void _cancelRegistration(EventRegistration registration) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Cancel Registration',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Are you sure you want to cancel this registration?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'No',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    final index = _allRegistrations.indexWhere(
                      (r) => r.id == registration.id,
                    );
                    if (index != -1) {
                      _allRegistrations[index] = registration.copyWith(
                        status: EventRegistrationStatus.cancelled,
                      );
                    }
                  });
                  Navigator.pop(context);
                  _showSnackBar('Registration cancelled', AppColors.danger);
                },
                child: const Text(
                  'Yes, Cancel',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
    );
  }

  void _showSubmissionDateFilter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Filter by Submission Date',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Start Date',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    _filterSubmissionStartDate?.toString().split(' ')[0] ??
                        'Not selected',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterSubmissionStartDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
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
                  title: const Text(
                    'End Date',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    _filterSubmissionEndDate?.toString().split(' ')[0] ??
                        'Not selected',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterSubmissionEndDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showEventFilter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Filter by Event',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'All Events',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
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
                ..._events.map(
                  (event) => ListTile(
                    title: Text(
                      event.title,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
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
                  ),
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
                  setState(() {});
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showActivityTypeFilter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Filter by Activity Type',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'All Types',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedActivityTypeFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityTypeFilter = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                ...activityTypes.map(
                  (type) => ListTile(
                    title: Text(
                      type['name'],
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: Radio<String>(
                      value: type['code'],
                      groupValue: _selectedActivityTypeFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityTypeFilter = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
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
                  setState(() {});
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showActivityStatusFilter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Filter by Activity Status',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'All Statuses',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedActivityStatusFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityStatusFilter = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                ...activityStatus.map(
                  (status) => ListTile(
                    title: Text(
                      status['name'],
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    leading: Radio<String>(
                      value: status['code'],
                      groupValue: _selectedActivityStatusFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityStatusFilter = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
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
                  setState(() {});
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filterSubmissionStartDate = null;
      _filterSubmissionEndDate = null;
      _selectedEventFilter = null;
      _selectedActivityTypeFilter = null;
      _selectedActivityStatusFilter = null;
    });
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
