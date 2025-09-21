import 'package:flutter/material.dart';
import 'package:bicycle_rental_center/models/bike_group.dart';
import 'package:bicycle_rental_center/services/activity_service.dart';
import 'booking_form_screen.dart';


class BicycleSelectionScreen extends StatefulWidget {
  final String centerActivityUuid;

  const BicycleSelectionScreen({super.key, required this.centerActivityUuid});

  @override
  State<BicycleSelectionScreen> createState() => _BicycleSelectionScreenState();
}

class _BicycleSelectionScreenState extends State<BicycleSelectionScreen> {
  List<BikeGroup> bicycles = [];
  bool isLoading = true;
  String? errorMessage;
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _loadBicycles();
  }

  Future<void> _loadBicycles() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedBicycles = await _activityService.getCenterActivityBicycles(
        widget.centerActivityUuid,
      );

      setState(() {
        bicycles = fetchedBicycles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load bicycles. Please try again.';
      });
    }
  }

  IconData _getBikeTypeIcon(String typeCode) {
    switch (typeCode) {
      case 'CITY_BIKES':
        return Icons.directions_bike;
      case 'ELECTRIC_BIKES':
        return Icons.electric_bike;
      case 'MOUNTAIN_BIKES':
        return Icons.terrain;
      default:
        return Icons.directions_bike;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Available Bicycles'),
        backgroundColor: Colors.black,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBicycles,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...bicycles.map((bicycle) {
                    final totalBikes =
                        bicycle.availableBikes.length +
                        bicycle.rentedBikes.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bike type header with availability info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getBikeTypeIcon(bicycle.typeCode),
                                color:
                                    bicycle.availableBikes.isNotEmpty
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bicycle.typeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${bicycle.availableBikes.length} available • $totalBikes total',
                                    style: TextStyle(
                                      color:
                                          bicycle.availableBikes.isNotEmpty
                                              ? Colors.green
                                              : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Available bikes list
                        if (bicycle.availableBikes.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Available Bikes:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ...bicycle.availableBikes.map((bike) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.grey[800],
                              child: ListTile(
                                leading: const Icon(
                                  Icons.directions_bike,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  '${bike.makeName} ${bike.modelName}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'QR: ${bike.qrCode}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BookingFormScreen(
                                              centerActivityUuid:
                                                  widget.centerActivityUuid,
                                              selectedBike: bike,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ],

                        // Rented bikes list (collapsed by default)
                        if (bicycle.rentedBikes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ExpansionTile(
                            initiallyExpanded: false,
                            collapsedBackgroundColor: Colors.grey[850],
                            backgroundColor: Colors.grey[800],
                            title: Text(
                              '${bicycle.rentedBikes.length} rented bikes',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            children: [
                              ...bicycle.rentedBikes.map((bike) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  color: Colors.grey[700],
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.directions_bike,
                                      color: Colors.white54,
                                    ),
                                    title: Text(
                                      '${bike.makeName} ${bike.modelName}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'QR: ${bike.qrCode}',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
    );
  }
}
