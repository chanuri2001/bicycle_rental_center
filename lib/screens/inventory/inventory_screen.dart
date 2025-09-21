import 'package:bicycle_rental_center/models/bicycle.dart';
import 'package:bicycle_rental_center/services/api_service.dart';
import 'package:bicycle_rental_center/services/auth_service.dart';
import 'package:bicycle_rental_center/services/center_bicycle_service.dart';
import 'package:bicycle_rental_center/services/user_info_service.dart';
import 'package:bicycle_rental_center/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'add_edit_bicycle_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Data state
  List<Bicycle> _bicycles = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _searchQuery = '';
  String? _centerUuid;
  String? _centerName;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;

  // Filters
  String _selectedStatusFilter = 'All';
  String? _selectedTypeFilter;
  List<String> _availableTypes = ['All Types'];
  bool _isSearching = false;

  // Services
  final AuthService _authService = AuthService();
  late final BicycleService _bicycleService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bicycleService = BicycleService(_authService);
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Initial data loading
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _loadBicycles(resetPagination: true);
    } catch (e) {
      _showErrorSnackBar('Failed to load initial data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Main data loading function
  Future<void> _loadBicycles({bool resetPagination = false}) async {
    if (resetPagination) {
      setState(() {
        _currentPage = 1;
        _hasMoreItems = true;
        _bicycles = [];
      });
    }

    setState(() => _isLoadingMore = true);

    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('No access token');

      final user = await UserService.fetchUserInfo(token);
      if (user?.centerUserAccess.isEmpty ?? true) {
        throw Exception('No center access');
      }

      final centerAccess = user!.centerUserAccess.first;
      _centerUuid = centerAccess.center.uuid;
      _centerName = centerAccess.center.name;

      final response = await CenterBicycleService.fetchCenterBicycles(
        token: token,
        centerUuid: _centerUuid!,
        page: _currentPage,
        limit: _itemsPerPage,
        status: _selectedStatusFilter == 'All' ? null : _selectedStatusFilter,
        type: _selectedTypeFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response != null && response.status) {
        final newBicycles =
            response.result.centerBicycles.map((cb) => Bicycle.fromCenterBicycle(cb)).toList();

        setState(() {
          if (resetPagination) {
            _bicycles = newBicycles;
          } else {
            _bicycles.addAll(newBicycles);
          }

          // Update available types for filtering
          _availableTypes = [
            'All Types',
            ..._bicycles.map((b) => b.types).toSet().toList(),
          ];

          _hasMoreItems = newBicycles.length == _itemsPerPage;
        });
      } else {
        throw Exception('Failed to load bicycles');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading bicycles: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingMore = false;
        _isRefreshing = false;
      });
    }
  }

  // Load more data when scrolling
  Future<void> _loadMoreBicycles() async {
    if (!_hasMoreItems || _isLoadingMore) return;
    setState(() => _currentPage++);
    await _loadBicycles();
  }

  // Handle scroll events
  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMoreItems &&
        !_isLoadingMore) {
      _loadMoreBicycles();
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadBicycles(resetPagination: true);
  }

  // Filter bicycles based on search and filters
  List<Bicycle> get _filteredBicycles {
    return _bicycles.where((bike) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          bike.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bike.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bike.types.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bike.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bike.qrCode.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType =
          _selectedTypeFilter == null || bike.types == _selectedTypeFilter;

      return matchesSearch && matchesType;
    }).toList();
  }

  // Get bicycle counts for summary
  Map<String, int> _getBicycleCounts() {
    return {'total': _bicycles.length};
  }

  // Navigation to add/edit screens
  void _addBicycle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditBicycleScreen(
          bicycleService: _bicycleService,
          centerUuid: _centerUuid,
          centerName: _centerName,
        ),
      ),
    );

    if (result != null && result is Bicycle) {
      await _loadBicycles(resetPagination: true);
      _showSuccessSnackBar('Bicycle added successfully!');
    }
  }

  void _editBicycle(Bicycle bicycle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditBicycleScreen(
          bicycle: bicycle,
          bicycleService: _bicycleService,
          centerUuid: _centerUuid,
          centerName: _centerName,
        ),
      ),
    );

    if (result != null) {
      if (result is bool && result) {
        await _loadBicycles(resetPagination: true);
        _showSuccessSnackBar('Bicycle deleted successfully!');
      } else if (result is Bicycle) {
        await _loadBicycles(resetPagination: true);
        _showSuccessSnackBar('Bicycle updated successfully!');
      }
    }
  }

  // Delete bicycle
  Future<void> _deleteBicycle(Bicycle bicycle) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this bicycle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final token = await _authService.getAccessToken();
        if (token == null) throw Exception('No access token');

        final success = await _bicycleService.deleteBicycle(
          token: token,
          bicycleUuid: bicycle.id,
        );

        if (success) {
          await _loadBicycles(resetPagination: true);
          _showSuccessSnackBar('Bicycle deleted successfully!');
        } else {
          throw Exception('Failed to delete bicycle');
        }
      } catch (e) {
        _showErrorSnackBar('Error deleting bicycle: ${e.toString()}');
      }
    }
  }

  // Snackbar helpers
  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, AppColors.success);
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, AppColors.danger);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempTypeFilter = _selectedTypeFilter;
        String tempStatusFilter = _selectedStatusFilter;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Filter Options',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bicycle Type',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempTypeFilter,
                      dropdownColor: Colors.grey[800],
                      decoration: InputDecoration(
                        hintText: 'Select type',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: _availableTypes.map((type) {
                        return DropdownMenuItem(
                          value: type == 'All Types' ? null : type,
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => tempTypeFilter = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedStatusFilter = 'All';
                      _selectedTypeFilter = null;
                      _currentPage = 1;
                    });
                    _loadBicycles(resetPagination: true);
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedStatusFilter = tempStatusFilter;
                      _selectedTypeFilter = tempTypeFilter;
                      _currentPage = 1;
                    });
                    _loadBicycles(resetPagination: true);
                  },
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBicycles = _filteredBicycles;
    final counts = _getBicycleCounts();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _isSearching
            ? _buildSearchField()
            : const Text(
                'Bicycle Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: _buildAppBarActions(),
      ),
      body: _buildMainContent(filteredBicycles, counts),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBicycle,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // App bar search field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFF4CAF50),
      decoration: InputDecoration(
        hintText: 'Search bicycles...',
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
            _loadBicycles(resetPagination: true);
          },
        ),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
        _loadBicycles(resetPagination: true);
      },
    );
  }

  // App bar actions
  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4CAF50)),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
            _loadBicycles(resetPagination: true);
          },
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
        onPressed: () => setState(() => _isSearching = true),
      ),
      IconButton(
        icon: const Icon(Icons.filter_list, color: Color(0xFF4CAF50)),
        onPressed: _showFilterDialog,
      ),
      IconButton(
        icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
        onPressed: _refreshData,
      ),
    ];
  }

  // Main content area
  Widget _buildMainContent(
    List<Bicycle> filteredBicycles,
    Map<String, int> counts,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF4CAF50),
      backgroundColor: Colors.grey[900],
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Summary section
          SliverToBoxAdapter(child: _buildSummarySection(counts)),

          // Active filters
          if (_selectedTypeFilter != null)
            SliverToBoxAdapter(child: _buildActiveFilters()),

          // Content
          _buildContentSection(filteredBicycles),

          // Loading and end indicators
          _buildLoadingAndEndIndicators(),
        ],
      ),
    );
  }

  // Summary section
  Widget _buildSummarySection(Map<String, int> counts) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryChip(
            'Total Bikes',
            counts['total']!,
            const Color(0xFF4CAF50),
            Icons.directions_bike,
          ),
          Text(
            'Page $_currentPage',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Active filters display
  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedTypeFilter != null)
            Chip(
              label: Text(
                'Type: $_selectedTypeFilter',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey[800],
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedTypeFilter = null;
                  _currentPage = 1;
                });
                _loadBicycles(resetPagination: true);
              },
            ),
        ],
      ),
    );
  }

  // Main content section
  Widget _buildContentSection(List<Bicycle> filteredBicycles) {
    if (_isLoading && _bicycles.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildShimmerLoader(),
          childCount: 1,
        ),
      );
    }

    if (filteredBicycles.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index < filteredBicycles.length) {
          return _buildBicycleCard(filteredBicycles[index]);
        }
        return const SizedBox.shrink();
      }, childCount: filteredBicycles.length),
    );
  }

  // Loading and end indicators
  Widget _buildLoadingAndEndIndicators() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
            ),
          if (_bicycles.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'End of inventory list',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ||
                      _selectedStatusFilter != 'All' ||
                      _selectedTypeFilter != null
                  ? 'No bicycles match your search criteria'
                  : 'Your inventory is empty',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ||
                      _selectedStatusFilter != 'All' ||
                      _selectedTypeFilter != null
                  ? 'Try adjusting your filters or search term'
                  : 'Add your first bicycle to get started',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addBicycle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Add New Bicycle'),
            ),
          ],
        ),
      ),
    );
  }

  // Bicycle card widget
  Widget _buildBicycleCard(Bicycle bike) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _editBicycle(bike),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with name, status, and action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bike.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusIndicator(bike.condition),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editBicycle(bike),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBicycle(bike),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bike details
                _buildDetailRow(
                  icon: Icons.branding_watermark,
                  label: 'Brand',
                  value: bike.makeName,
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  icon: Icons.directions_bike,
                  label: 'Model',
                  value: bike.modelName,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Type',
                      value: bike.types,
                    ),
                    const Spacer(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Year',
                      value: bike.makeYear.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: bike.location,
                  isEditable: false, // Make location uneditable
                ),
                const SizedBox(height: 12),

                // Tags row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (bike.qrCode.isNotEmpty)
                      _buildTagChip(
                        'QR: ${bike.qrCode}',
                        Icons.qr_code,
                        const Color(0xFF4CAF50),
                      ),
                    _buildTagChip(bike.condition, Icons.star, Colors.amber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Status indicator widget
  Widget _buildStatusIndicator(String condition) {
    Color statusColor;
    switch (condition.toLowerCase()) {
      case 'excellent':
        statusColor = Colors.green;
        break;
      case 'good':
        statusColor = Colors.lightGreen;
        break;
      case 'fair':
        statusColor = Colors.orange;
        break;
      case 'poor':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Detail row widget
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                value,
                style: TextStyle(
                  color: isEditable ? Colors.white : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tag chip widget
  Widget _buildTagChip(String text, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  // Summary chip widget
  Widget _buildSummaryChip(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}