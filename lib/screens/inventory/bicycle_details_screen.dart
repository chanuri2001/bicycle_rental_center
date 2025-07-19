import 'package:flutter/material.dart';
import 'package:bicycle_rental_center/screens/rental_form_screen.dart';
import '../../models/bicycle.dart';

class BicycleDetailsScreen extends StatelessWidget {
  final Bicycle bicycle;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const BicycleDetailsScreen({
    super.key,
    required this.bicycle,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Bicycle Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bicycle Image
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _getBikeImage(bicycle),
                  ),
                ),
                const SizedBox(height: 20),

                // Bicycle Name and Type
                Text(
                  bicycle.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    bicycle.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price per hour
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: 'Price per hour',
                  value: '\$${bicycle.pricePerHour.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 15),

                // Location
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: bicycle.location,
                ),
                const SizedBox(height: 15),

                // Condition
                _buildDetailRow(
                  icon: Icons.build,
                  label: 'Condition',
                  value: bicycle.condition,
                ),
                const SizedBox(height: 15),

                // Availability Status
                _buildDetailRow(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: bicycle.isAvailable ? 'Available' : 'Not Available',
                  valueColor: bicycle.isAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 15),

                // Description
                if (bicycle.description.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: bicycle.description,
                  ),
                  const SizedBox(height: 15),
                ],

                // Quantity Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inventory',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuantityInfo(
                            'Available',
                            bicycle.availableCount.toString(),
                            Colors.green,
                          ),
                          _buildQuantityInfo(
                            'Rented',
                            bicycle.rentedCount.toString(),
                            Colors.orange,
                          ),
                          _buildQuantityInfo(
                            'Total',
                            bicycle.totalCount.toString(),
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Selected Date and Time (if available)
                if (selectedDate != null && selectedTime != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Time',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),

                // Rent Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        bicycle.isAvailable
                            ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => RentalFormScreen(
                                        selectedBike: bicycle,
                                        selectedDate: selectedDate,
                                        selectedTime: selectedTime,
                                      ),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          bicycle.isAvailable ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      bicycle.isAvailable
                          ? 'Rent This Bicycle'
                          : 'Not Available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _getBikeImage(Bicycle bike) {
    if (bicycle.imageFile != null) {
      return Image.file(bicycle.imageFile!, fit: BoxFit.cover);
    }

    if (bicycle.imageUrl != null && bicycle.imageUrl!.isNotEmpty) {
      return Image.network(
        bicycle.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    }

    // Default image based on bike type
    String imagePath;
    switch (bike.type.name) {
      case 'mountain':
        imagePath =
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400&h=400&fit=crop&auto=format';
        break;
      case 'road':
        imagePath =
            'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400&h=400&fit=crop&auto=format';
        break;
      case 'electric':
        imagePath =
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400&h=400&fit=crop&auto=format';
        break;
      case 'hybrid':
        imagePath =
            'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?w=400&h=400&fit=crop&auto=format';
        break;
      default:
        imagePath =
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400&h=400&fit=crop&auto=format';
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.directions_bike,
          size: 60,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
