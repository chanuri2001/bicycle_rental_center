import 'package:bicycle_rental_center/screens/events/add_edit_event_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data with better image URLs
    _events = [
      Event(
        id: '1',
        activityName: 'Mountain Bike Rally',

        activityShortDescription:
            'Join us for an exciting mountain bike rally through scenic trails',
        date: DateTime.now().add(const Duration(days: 7)),
        eventTime: DateTime.now().add(const Duration(days: 7)),
        centerName: 'Mountain Trail Park',
        maxParticipants: 50,

        eligibilityCriteria: 'Age 16+, Basic cycling experience required',
        durationHours: 4,
        features: [
          'Scenic trails',
          'Professional guides',
          'Safety equipment included',
        ],
        activityTypeName: 'Intermediate',

        imageUrl:
            'https://www.ambmag.com.au/wp-content/uploads/2025/06/Copy-of-NZ-MTB-RALLY-DAY-3-%C2%A9Mikhail-Huggins-@macca._h-83-2048x1365.jpg', centerActivityUuid: '',
        
      ),
      Event(
        id: '2',
        activityName: 'City Cycling Tour',

        activityShortDescription:
            'Explore the city on two wheels with our guided tour',
        date: DateTime.now().add(const Duration(days: 14)),
        eventTime: DateTime.now().add(const Duration(days: 14)),
        centerName: 'Downtown City Center',
        maxParticipants: 30,

        eligibilityCriteria: 'Age 12+, No experience required',
        durationHours: 2,
        features: ['City landmarks', 'Photo stops', 'Local guide'],
        activityTypeName: 'Easy',

        imageUrl:
            'https://veronikasadventure.com/wp-content/uploads/2024/08/polonnaruwa-ancient-city-cycling-day-tour-from-negombo.jpg', centerActivityUuid: '',
        
      ),
     
    ];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditEventScreen(),
                ),
              );

              if (result != null && result is Event) {
                setState(() {
                  _events.add(result);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event added successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : RefreshIndicator(
                onRefresh: _loadEvents,
                child:
                    _events.isEmpty
                        ? const Center(
                          child: Text(
                            'No events found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return _buildEventCard(event);
                          },
                        ),
              ),
    );
  }

  Widget _buildEventCard(Event event) {
    final daysUntilEvent = event.date.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.borderRadius),
              topRight: Radius.circular(AppConstants.borderRadius),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                event.imageUrl.isNotEmpty
                    ? event.imageUrl
                    : 'https://via.placeholder.com/400x200?text=No+Image',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: AppColors.darkBackground,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            daysUntilEvent <= 7
                                ? AppColors.warning.withOpacity(0.2)
                                : AppColors.info.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        daysUntilEvent == 0
                            ? 'Today'
                            : daysUntilEvent == 1
                            ? 'Tomorrow'
                            : '${daysUntilEvent}d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              daysUntilEvent <= 7
                                  ? AppColors.warning
                                  : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  event.activityShortDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Event Details
                Row(
                  children: [
                    _buildEventInfo(Icons.calendar_today, event.formattedDate),
                    const SizedBox(width: 16),
                    _buildEventInfo(Icons.access_time, event.formattedTime),
                    const SizedBox(width: 16),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildEventInfo(Icons.location_on, event.centerName),
                    const SizedBox(width: 16),
                    _buildEventInfo(Icons.straighten, event.activityTypeName),
                  ],
                ),

                const SizedBox(height: 16),

                // Features
                if (event.features.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        event.features
                            .take(3)
                            .map(
                              (feature) => Chip(
                                label: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: AppColors.darkBackground,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),

                const SizedBox(height: 16),

                // Participants Count and Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Participants Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${event.maxParticipants} max',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _editEvent(event),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.danger,
                          ),
                          onPressed: () => _deleteEvent(event),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: AppColors.darkBackground,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _editEvent(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditEventScreen(event: event)),
    );

    if (result != null && result is Event) {
      setState(() {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Delete Event',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${event.activityName}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _events.removeWhere((e) => e.id == event.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${event.activityName} deleted successfully!',
                    ),
                    backgroundColor: AppColors.danger,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }
}
