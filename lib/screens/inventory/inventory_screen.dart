import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/bicycle.dart';
import '../../models/bike_type.dart';
import 'add_edit_bicycle_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Bicycle> _bicycles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBicycles();
  }

  Future<void> _loadBicycles() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    _bicycles = BikeData.getAllBikes();

    setState(() {
      _isLoading = false;
    });
  }

  List<Bicycle> get _filteredBicycles {
    List<Bicycle> filtered = _bicycles;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bicycle) =>
          bicycle.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bicycle.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bicycle.type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bicycle.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedFilter != 'All') {
      filtered = filtered.where((bicycle) => bicycle.type.name == _selectedFilter.toLowerCase()).toList();
    }

    return filtered;
  }

  void _addBicycle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditBicycleScreen()),
    );

    if (result != null && result is Bicycle) {
      setState(() {
        _bicycles.add(result);
      });
      _showSnackBar('Bicycle added successfully!', AppColors.success);
    }
  }

  void _editBicycle(Bicycle bicycle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditBicycleScreen(bicycle: bicycle),
      ),
    );

    if (result != null && result is Bicycle) {
      setState(() {
        final index = _bicycles.indexWhere((b) => b.id == bicycle.id);
        if (index != -1) {
          _bicycles[index] = result;
        }
      });
      _showSnackBar('Bicycle updated successfully!', AppColors.success);
    }
  }

  void _deleteBicycle(Bicycle bicycle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Delete Bicycle',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${bicycle.fullName}"? This action cannot be undone.',
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
                  _bicycles.removeWhere((b) => b.id == bicycle.id);
                });
                _showSnackBar(
                  'Bicycle deleted successfully!',
                  AppColors.danger,
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.success),
            onPressed: _loadBicycles,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search bicycles...',
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      ...BikeType.values.map((type) => type.displayName)
                    ].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: AppColors.cardBackground,
                          selectedColor: AppColors.success.withOpacity(0.3),
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.success,
                    ),
                  )
                : _filteredBicycles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bike,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedFilter != 'All'
                                  ? 'No bicycles match your search'
                                  : 'No bicycles in inventory',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _addBicycle,
                              child: const Text('Add New Bicycle'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBicycles,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBicycles.length,
                          itemBuilder: (context, index) {
                            final bicycle = _filteredBicycles[index];
                            return _buildBicycleCard(bicycle);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBicycle,
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBicycleCard(Bicycle bicycle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.borderRadius),
              topRight: Radius.circular(AppConstants.borderRadius),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              color: AppColors.darkBackground,
              child: _getBikeImage(bicycle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bicycle.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bicycle.type.displayName,
                            style: const TextStyle(
                              fontSize: 14,
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
                        color: bicycle.isAvailable
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.danger.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bicycle.isAvailable ? 'Available' : 'Rented',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: bicycle.isAvailable
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${bicycle.location}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bicycle.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInventoryChip(
                      '\$${bicycle.pricePerHour.toStringAsFixed(2)}/hr',
                      Icons.attach_money,
                    ),
                    const SizedBox(width: 8),
                    _buildInventoryChip(
                      'Total: ${bicycle.totalCount}',
                      Icons.inventory,
                    ),
                    const SizedBox(width: 8),
                    _buildInventoryChip(
                      'Avail: ${bicycle.availableCount}',
                      Icons.check_circle,
                      color: bicycle.availableCount > 0 
                          ? AppColors.success 
                          : AppColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInventoryChip(
                      bicycle.condition,
                      Icons.star,
                    ),
                    const Spacer(),
                    if (bicycle.rentedCount > 0)
                      _buildInventoryChip(
                        'Rented: ${bicycle.rentedCount}',
                        Icons.directions_bike,
                        color: AppColors.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editBicycle(bicycle),
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
                        onPressed: () => _deleteBicycle(bicycle),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ),
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

  Widget _buildInventoryChip(String text, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBikeImage(Bicycle bike) {
    if (bike.imageFile != null) {
      return Image.file(bike.imageFile!, fit: BoxFit.cover);
    } else if (bike.imageUrl != null) {
      return Image.network(
        bike.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.darkBackground,
      child: const Center(
        child: Icon(
          Icons.directions_bike,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class BikeData {
  static List<Bicycle> getAllBikes() {
    return [
      Bicycle(
        id: '1',
        name: 'Trek 520',
        brand: 'Trek',
        type: BikeType.mountain,
        location: 'Downtown Center',
        pricePerHour: 15.99,
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        imageUrl: 'assets/images/mountain_bike.png',
        description: 'Professional mountain bike with full suspension',
      ),
      Bicycle(
        id: '2',
        name: 'Allez',
        brand: 'Specialized',
        type: BikeType.road,
        location: 'Park Center',
        pricePerHour: 18.99,
        totalCount: 4,
        availableCount: 2,
        rentedCount: 2,
        imageUrl: 'assets/images/road_bike.png',
        description: 'Lightweight road bike for speed',
      ),
      Bicycle(
        id: '3',
        name: 'Urban Cruiser',
        brand: 'Urban',
        type: BikeType.hybrid,
        location: 'Downtown Center',
        pricePerHour: 20.99,
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        imageUrl: 'assets/images/hybrid_bike.png',
        description: 'Comfortable hybrid for city riding',
      ),
      Bicycle(
        id: '4',
        name: 'Thunder X1',
        brand: 'Thunder',
        type: BikeType.electric,
        location: 'Tech Hub',
        pricePerHour: 45.99,
        totalCount: 3,
        availableCount: 1,
        rentedCount: 2,
        imageUrl: 'assets/images/electric_bike.png',
        description: 'Powerful electric bike with long range',
      ),
    ];
  }
}