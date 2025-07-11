import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/bicycle.dart';
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

    _bicycles = [
      Bicycle(
        id: '1',
        name: 'Mountain Explorer Pro',
        type: 'Mountain',
        isAvailable: true,
        pricePerHour: 15.0,
        description: 'Professional mountain bike with advanced suspension',
        imageUrl:
            'https://hyperbicycles.com/cdn/shop/products/29in-hyper-explorer-mtb-hard-tail-blue_1_720x.jpg?v=1614987504',
        count: 3,
        condition: 'Excellent',
      ),
      Bicycle(
        id: '2',
        name: 'City Cruiser Deluxe',
        type: 'City',
        isAvailable: false,
        pricePerHour: 10.0,
        description: 'Comfortable city bike perfect for urban commuting',
        imageUrl:
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
        count: 2,
        condition: 'Good',
      ),
      Bicycle(
        id: '3',
        name: 'Road Rocket Elite',
        type: 'Road',
        isAvailable: true,
        pricePerHour: 22.0,
        description: 'Ultra-lightweight racing bike with carbon fiber frame',
        imageUrl: 'https://i.redd.it/34xhv0zdo6001.jpg',
        count: 2,
        condition: 'Excellent',
      ),
      Bicycle(
        id: '4',
        name: 'Electric Voyager',
        type: 'Electric',
        isAvailable: true,
        pricePerHour: 28.0,
        description: 'Power-assisted e-bike with 60-mile battery range',
        imageUrl:
            'https://content.syndigo.com/asset/003c74d4-a78e-4125-9f87-590f46062fb7/1500.jpg',
        count: 1,
        condition: 'Good',
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<Bicycle> get _filteredBicycles {
    List<Bicycle> filtered = _bicycles;

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (bicycle) =>
                    bicycle.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    bicycle.type.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((bicycle) => bicycle.type == _selectedFilter).toList();
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
            'Are you sure you want to delete "${bicycle.name}"? This action cannot be undone.',
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
                    children:
                        ['All', 'Mountain', 'City', 'Road', 'Electric'].map((
                          filter,
                        ) {
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
                                color:
                                    _selectedFilter == filter
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
            child:
                _isLoading
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
              height: 200,
              width: double.infinity,
              color: AppColors.darkBackground,
              child:
                  bicycle.imageFile != null
                      ? Image.file(bicycle.imageFile!, fit: BoxFit.cover)
                      : bicycle.imageUrl != null
                      ? Image.network(
                        bicycle.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                      : _buildPlaceholderImage(),
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
                            bicycle.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bicycle.type,
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
                        color:
                            bicycle.isAvailable
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.danger.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bicycle.isAvailable ? 'Available' : 'Rented',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              bicycle.isAvailable
                                  ? AppColors.success
                                  : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bicycle.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.attach_money,
                      '\$${bicycle.pricePerHour.toStringAsFixed(0)}/hr',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.inventory, '${bicycle.count} units'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.star, bicycle.condition),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
