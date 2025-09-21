import 'package:bicycle_rental_center/models/bike_group.dart';
import 'package:bicycle_rental_center/screens/inventory/bicycle_details_screen.dart';
import 'package:bicycle_rental_center/screens/rental_form_screen.dart';
import 'package:bicycle_rental_center/services/bicycle_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BicycleAvailabilityScreen extends StatefulWidget {
  const BicycleAvailabilityScreen({super.key});

  @override
  State<BicycleAvailabilityScreen> createState() =>
      _BicycleAvailabilityScreenState();
}

class _BicycleAvailabilityScreenState extends State<BicycleAvailabilityScreen> {
  Future<List<BikeGroup>>? _futureBikes;
  final String centerActivityUuid = "CA-AC784B4744";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    if (accessToken != null && accessToken.isNotEmpty) {
      setState(() {
        _futureBikes = BikeService().fetchBikes(
          "Bearer $accessToken",
          centerActivityUuid,
        );
      });
    } else {
      setState(() {
        _futureBikes = Future.error(
          "Access token not found. Please log in again.",
        );
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  void _navigateToRentalForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RentalFormScreen(
              selectedBike: null,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
            ),
      ),
    );
  }

  void _navigateToBicycleDetails(bike) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BicycleDetailsScreen(
              bicycle: bike,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Bicycle Availability"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null || selectedTime == null
                          ? 'Select Date & Time'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _navigateToRentalForm,
            icon: const Icon(Icons.add),
            label: const Text("Create Rental Request"),
          ),
          Expanded(
            child:
                _futureBikes == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<BikeGroup>>(
                      future: _futureBikes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No bicycles available."),
                          );
                        } else {
                          final groups = snapshot.data!;
                          final allBikes =
                              groups.expand((g) => g.totalBikes).toList();

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: allBikes.length,
                            itemBuilder: (context, index) {
                              final bike = allBikes[index];
                              final group = groups.firstWhere(
                                (g) => g.totalBikes.contains(bike),
                              );

                              final availableCount =
                                  group.availableBikes
                                      .where((b) => b.id == bike.id)
                                      .length;
                              final rentedCount =
                                  group.rentedBikes
                                      .where((b) => b.id == bike.id)
                                      .length;
                              final totalCount =
                                  group.totalBikes
                                      .where((b) => b.id == bike.id)
                                      .length;

                              return GestureDetector(
                                onTap: () => _navigateToBicycleDetails(bike),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: Image.asset(
                                            'assets/images/bike_placeholder.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              group.typeName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.directions_bike,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              bike.modelName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Location: ${bike.location}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),

                                            Text(
                                              'QR: ${bike.qrCode} | Make: ${bike.makeName}',
                                            ),

                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Available: $availableCount',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Rented: $rentedCount',
                                                    style: const TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total: $totalCount bikes',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'AVAILABLE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
