import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rental_request.dart';
import '../../models/bicycle.dart';
import '../../utils/constants.dart';

class BikeRentalDetailsScreen extends StatelessWidget {
  final Bicycle bicycle;
  final List<RentalRequest> allBookings;

  const BikeRentalDetailsScreen({
    super.key,
    required this.bicycle,
    required this.allBookings,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find all bookings that include this bike
    final bikeBookings =
        allBookings.where((booking) {
          return booking.bikes.any((bike) => bike['bike_id'] == bicycle.id);
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('${bicycle.makeName} ${bicycle.modelName}'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bike information card
            Card(
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bike,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${bicycle.makeName} ${bicycle.modelName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code: ${bicycle.qrCode}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Condition: ${bicycle.condition}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rental history section
            const Text(
              'Rental History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (bikeBookings.isEmpty)
              const Text(
                'No rental history found',
                style: TextStyle(color: Colors.white70),
              )
            else
              Column(
                children:
                    bikeBookings.map((booking) {
                      final bikeInBooking = booking.findBike(bicycle.id);
                      return Card(
                        color: const Color(0xFF2A2A2A),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    booking.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Dates:',
                                '${DateFormat('MMM dd, yyyy').format(booking.pickupDate)} - ${DateFormat('MMM dd, yyyy').format(booking.returnDate)}',
                              ),
                              if (bikeInBooking != null &&
                                  bikeInBooking['actualPickupTime'] != null)
                                _buildDetailRow(
                                  'Picked up:',
                                  DateFormat(
                                    'MMM dd, yyyy - hh:mm a',
                                  ).format(bikeInBooking['actualPickupTime']),
                                ),
                              if (bikeInBooking != null &&
                                  bikeInBooking['actualReturnTime'] != null)
                                _buildDetailRow(
                                  'Returned:',
                                  DateFormat(
                                    'MMM dd, yyyy - hh:mm a',
                                  ).format(bikeInBooking['actualReturnTime']),
                                ),
                              if (bikeInBooking != null &&
                                  bikeInBooking['accessories'] != null &&
                                  (bikeInBooking['accessories'] as List)
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Accessories:',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    ...(bikeInBooking['accessories'] as List)
                                        .map(
                                          (accessory) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              top: 4,
                                            ),
                                            child: Text(
                                              '• ${accessory['name']} (${accessory['quantity']}x)',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Total Cost:',
                                '\$${booking.totalCost.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
}
