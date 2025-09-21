import 'package:bicycle_rental_center/models/bicycle.dart';
import 'package:bicycle_rental_center/models/rental_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bicycle.dart';
import '../data/bike_data.dart';

class RentalFormScreen extends StatefulWidget {
  final Bicycle? selectedBike;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const RentalFormScreen({
    super.key,
    this.selectedBike,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers for user info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  // Controllers for other person info
  final _otherNameController = TextEditingController();
  final _otherEmailController = TextEditingController();
  final _otherPhoneController = TextEditingController();
  final _otherLicenseController = TextEditingController();

  // Form state

  int _currentStep = 0;
  List<Bicycle> _availableBikes = [];
  List<Map<String, dynamic>> _selectedBikes = [];
  DateTime? _pickupDateTime;
  DateTime? _returnDateTime;

  // Payment and preferences
  String _paymentMethod = 'card';
  String _promoCode = '';
  bool _termsAccepted = false;
  bool _ageVerified = false;
  bool _damageResponsibility = false;

  @override
  void initState() {
    super.initState();
    _availableBikes =
        BikeData.getAllBikes().where((bike) => bike.isAvailable).toList();

    if (widget.selectedBike != null) {
      _selectedBikes.add({
        'bike': widget.selectedBike!,
        'quantity': 1,
        'helmet': false,
        'insurance': false,
        'lock': false,
      });
    }

    if (widget.selectedDate != null && widget.selectedTime != null) {
      _pickupDateTime = DateTime(
        widget.selectedDate!.year,
        widget.selectedDate!.month,
        widget.selectedDate!.day,
        widget.selectedTime!.hour,
        widget.selectedTime!.minute,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _otherNameController.dispose();
    _otherEmailController.dispose();
    _otherPhoneController.dispose();
    _otherLicenseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showBikeSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF16213E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.75, // Reduced from 0.8
              ),
              child: Padding(
                padding: const EdgeInsets.all(16), // Reduced from 20
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Bicycles',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Reduced from 20
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced from 20
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12, // Reduced from 15
                              crossAxisSpacing: 12, // Reduced from 15
                              childAspectRatio: 0.65, // Adjusted from 0.7
                            ),
                        itemCount: _availableBikes.length,
                        itemBuilder: (context, index) {
                          final bike = _availableBikes[index];
                          final isSelected = _selectedBikes.any(
                            (selected) => selected['bike'].id == bike.id,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedBikes.removeWhere(
                                    (selected) =>
                                        selected['bike'].id == bike.id,
                                  );
                                } else {
                                  _selectedBikes.add({
                                    'bike': bike,
                                    'quantity': 1,
                                    'helmet': false,
                                    'insurance': false,
                                    'lock': false,
                                  });
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Bike Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Container(
                                      height: 90, // Reduced from 100
                                      width: double.infinity,
                                      color: Colors.grey.shade100,
                                     
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bike.fullName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13, // Reduced from 14
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          bike.location,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11, // Reduced from 12
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        _buildQuantityChip(
                                          'Available: ${bike.availableCount}',
                                          bike.availableCount > 0
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ), // Reduced from 8
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10, // Reduced from 12
                                            vertical: 4, // Reduced from 6
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Colors.blue.withOpacity(
                                                      0.2,
                                                    )
                                                    : Colors.blue.withOpacity(
                                                      0.1,
                                                    ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            isSelected ? 'Selected' : 'Add',
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.blue
                                                      : Colors.blue.withOpacity(
                                                        0.7,
                                                      ),
                                              fontSize: 11, // Reduced from 12
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
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced from 20
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ), // Reduced height
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ), // Reduced height
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showBikeOptionsDialog(Map<String, dynamic> selectedBike) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF16213E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Options for ${selectedBike['bike'].fullName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bike Image
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                     
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accessories
                  _buildAccessoryCheckbox(
                    'Helmet (\$5)',
                    selectedBike['helmet'],
                    (value) {
                      setState(() {
                        selectedBike['helmet'] = value ?? false;
                      });
                    },
                  ),
                  _buildAccessoryCheckbox(
                    'Insurance (\$10)',
                    selectedBike['insurance'],
                    (value) {
                      setState(() {
                        selectedBike['insurance'] = value ?? false;
                      });
                    },
                  ),
                  _buildAccessoryCheckbox('Lock (\$3)', selectedBike['lock'], (
                    value,
                  ) {
                    setState(() {
                      selectedBike['lock'] = value ?? false;
                    });
                  }),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Options',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAccessoryCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  

   

  Widget _buildQuantityChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isPickup) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isPickup
              ? (_pickupDateTime ?? DateTime.now())
              : (_returnDateTime ??
                  DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isPickup) {
            _pickupDateTime = dateTime;
          } else {
            _returnDateTime = dateTime;
          }
        });
      }
    }
  }

  double _calculateTotalCost() {
    if (_pickupDateTime == null ||
        _returnDateTime == null ||
        _selectedBikes.isEmpty) {
      return 0.0;
    }

    final hours = _returnDateTime!.difference(_pickupDateTime!).inHours;
    double total = 0.0;

    for (var selectedBike in _selectedBikes) {
      final bike = selectedBike['bike'] as Bicycle;
      final quantity = selectedBike['quantity'] as int;
      double pricePerHour = 10.0;
      total += pricePerHour * hours * quantity;

      // Add accessories cost
      if (selectedBike['helmet'] as bool) total += 5;
      if (selectedBike['insurance'] as bool) total += 10;
      if (selectedBike['lock'] as bool) total += 3;
    }

    return total;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _validateForm()) {
      final rentalRequest = RentalRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: _nameController.text,
        userEmail: _emailController.text,
        userPhone: _phoneController.text,
        licenseNumber:
            _licenseController.text.isEmpty ? null : _licenseController.text,
        bikes:
            _selectedBikes.map((selected) {
              final bike = selected['bike'] as Bicycle;
              return {
                'bike_id': bike.id,
                'bike_model': bike.fullName,
                'quantity': selected['quantity'],
                'pickup_location': bike.location,
                'helmet': selected['helmet'],
                'insurance': selected['insurance'],
                'lock': selected['lock'],
              };
            }).toList(),
        submissionDate: DateTime.now(),
        pickupDate: _pickupDateTime!,
        returnDate: _returnDateTime!,
        totalCost: _calculateTotalCost(),
        deposit: _calculateTotalCost() * 0.3,
        paymentMethod: _paymentMethod,
        promoCode: _promoCode.isEmpty ? null : _promoCode,
        termsAccepted: _termsAccepted,
        ageVerified: _ageVerified,
        damageResponsibility: _damageResponsibility,
        status: RentalStatus.pending,
      );

      // Save or send the rental request
      _saveRentalRequest(rentalRequest);
    }
  }

  Future<void> _saveRentalRequest(RentalRequest request) async {
    // Here you would typically save to a database or API
    // For now, we'll just show a success dialog

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Request Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Your rental request has been submitted successfully!'),
                SizedBox(height: 16),
                Text('Total Cost: \$${request.totalCost.toStringAsFixed(2)}'),
                Text('Deposit: \$${request.deposit.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  bool _validateForm() {
    if (_selectedBikes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one bicycle')),
      );
      return false;
    }

    if (_pickupDateTime == null || _returnDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and return dates')),
      );
      return false;
    }

    if (!_termsAccepted || !_ageVerified || !_damageResponsibility) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept all agreements')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Rental Request',
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
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepIndicator(0, 'Info'),
                  _buildStepIndicator(1, 'Bikes'),
                  _buildStepIndicator(2, 'Details'),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildUserInfoStep(),
                  _buildBikeSelectionStep(),
                  _buildRentalDetailsStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep < 2 ? _nextStep : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep < 2 ? 'Continue' : 'Submit Request',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    bool isActive = stepIndex == _currentStep;
    bool isCompleted = stepIndex < _currentStep;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? Colors.blue : Colors.grey[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                      '${stepIndex + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            'Full Name',
            _nameController,
            'Enter your full name',
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            'Email Address',
            _emailController,
            'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (!value!.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            'Phone Number',
            _phoneController,
            'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            'License Number (Optional)',
            _licenseController,
            'Enter your license number',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBikeSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selected Bicycles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showBikeSelectionDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Bikes',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_selectedBikes.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bike,
                      size: 48,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No bicycles selected',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap "Add Bikes" to select bicycles',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children:
                  _selectedBikes.map((selected) {
                    final bike = selected['bike'] as Bicycle;
                    return GestureDetector(
                      onTap: () => _showBikeOptionsDialog(selected),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade800,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                               
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bike.fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    bike.location,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (selected['helmet'] as bool)
                                        _buildAccessoryChip(
                                          'Helmet',
                                          Colors.green,
                                        ),
                                      if (selected['insurance'] as bool)
                                        _buildAccessoryChip(
                                          'Insurance',
                                          Colors.blue,
                                        ),
                                      if (selected['lock'] as bool)
                                        _buildAccessoryChip(
                                          'Lock',
                                          Colors.orange,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedBikes.remove(selected);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAccessoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildRentalDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rental Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildDateTimeField(
            'Pickup Date & Time',
            _pickupDateTime,
            () => _selectDateTime(true),
          ),
          const SizedBox(height: 16),

          _buildDateTimeField(
            'Return Date & Time',
            _returnDateTime,
            () => _selectDateTime(false),
          ),
          const SizedBox(height: 20),

          const Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text(
                    'Credit/Debit Card',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'card',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  activeColor: Colors.blue,
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Cash',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'cash',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildTextField(
            'Promo Code (Optional)',
            TextEditingController(text: _promoCode),
            'Enter promo code',
            onChanged: (value) => _promoCode = value,
          ),

          const SizedBox(height: 20),

          const Text(
            'Agreements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildCheckboxTile(
            'I accept the terms and conditions',
            _termsAccepted,
            (value) {
              setState(() => _termsAccepted = value ?? false);
            },
          ),

          // Enhanced Age Verification Checkbox
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _ageVerified,
                  onChanged: (value) {
                    setState(() => _ageVerified = value ?? false);
                  },
                  activeColor: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'I verify that I am 18+ years old (Age verification required)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildCheckboxTile(
            'I accept responsibility for any damage',
            _damageResponsibility,
            (value) {
              setState(() => _damageResponsibility = value ?? false);
            },
          ),

          const SizedBox(height: 20),

          if (_pickupDateTime != null &&
              _returnDateTime != null &&
              _selectedBikes.isNotEmpty)
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
                    'Cost Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cost:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '\$${_calculateTotalCost().toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Deposit (30%):',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '\$${(_calculateTotalCost() * 0.3).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF16213E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(
    String label,
    DateTime? dateTime,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTime != null
                      ? '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${TimeOfDay.fromDateTime(dateTime).format(context)}'
                      : 'Select date and time',
                  style: TextStyle(
                    color: dateTime != null ? Colors.white : Colors.white54,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: dateTime != null ? Colors.blue : Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
