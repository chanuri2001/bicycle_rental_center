import 'package:bicycle_rental_center/api/bicycle_service.dart';
import 'package:bicycle_rental_center/models/bicycle_model.dart';
import 'package:flutter/material.dart';

class BicycleScreen extends StatefulWidget {
  const BicycleScreen({super.key});

  @override
  State<BicycleScreen> createState() => _BicycleScreenState();
}

class _BicycleScreenState extends State<BicycleScreen> {
  late Future<Map<String, List<dynamic>>> _bicyclesFuture;

  @override
  void initState() {
    super.initState();
    _bicyclesFuture = BicycleService.fetchBicycles();
  }

  Widget _buildBicycleList(List<dynamic> bikes, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...bikes.map((bikeJson) {
          final bike = Bicycle.fromJson(bikeJson);
          return Card(
            child: ListTile(
              title: Text('${bike.make} ${bike.model}'),
              subtitle: Text('QR Code: ${bike.qrCode}\nUUID: ${bike.uuid}'),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bicycle List")),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _bicyclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final available = snapshot.data?['available'] ?? [];
          final rented = snapshot.data?['rented'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildBicycleList(available, "Available Bicycles"),
                const SizedBox(height: 20),
                _buildBicycleList(rented, "Rented Bicycles"),
              ],
            ),
          );
        },
      ),
    );
  }
}
