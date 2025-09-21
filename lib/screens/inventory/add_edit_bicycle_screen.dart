import 'package:bicycle_rental_center/models/bicycle_meta.dart';
import 'package:bicycle_rental_center/services/api_service.dart';
import 'package:bicycle_rental_center/services/bicycle_service.dart';
import 'package:flutter/material.dart';
import '../../models/bicycle.dart';

class AddEditBicycleScreen extends StatefulWidget {
  final Bicycle? bicycle;
  final BicycleService bicycleService;
  final String? centerUuid;
  final String? centerName;
  final Function? onDelete; // Add this callback

  const AddEditBicycleScreen({
    super.key,
    this.bicycle,
    required this.bicycleService,
    this.centerUuid,
    this.centerName,
    this.onDelete,
  });

  @override
  State<AddEditBicycleScreen> createState() => _AddEditBicycleScreenState();
}

class _AddEditBicycleScreenState extends State<AddEditBicycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late Bicycle _currentBicycle;
  String? _selectedType;
  String? _selectedCondition;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedMakeYear;

  BicycleMeta? _bicycleMeta;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentBicycle = widget.bicycle ??
        Bicycle(
          id: '',
          qrCode: '',
          makeName: '',
          modelName: '',
          name: '',
          brand: '',
          types: '',
          location: widget.centerName ?? '',
          pricePerHour: 0.0,
          description: '',
          totalCount: 1,
          availableCount: 1,
          rentedCount: 0,
          centerName: widget.centerName ?? '',
          centerUuid: widget.centerUuid ?? '',
          makeYear: DateTime.now().year,
          condition: 'Good',
        );

    _selectedType = _currentBicycle.types;
    _loadBicycleMeta();
  }

  Future<void> _loadBicycleMeta() async {
    try {
      final meta = await widget.bicycleService.getBicycleMeta();
      setState(() {
        _bicycleMeta = meta;
        _selectedCondition = _findInitialValue(
          meta.conditionStatus.map((e) => e.name).toList(),
          _currentBicycle.condition,
        );
        _selectedMake = _findInitialValue(
          meta.makes.map((e) => e.name).toList(),
          _currentBicycle.makeName,
        );
        _selectedModel = _findInitialValue(
          meta.models.map((e) => e.name).toList(),
          _currentBicycle.modelName,
        );
        if (_currentBicycle.types.isNotEmpty) {
          _selectedType = _currentBicycle.types;
        } else if (meta.types.isNotEmpty) {
          _selectedType = meta.types.first.name;
        }
        _selectedMakeYear = _currentBicycle.makeYear;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load bicycle meta data: $e';
        _isLoading = false;
      });
    }
  }

  String? _findInitialValue(List<String> options, String? currentValue) {
    if (currentValue == null || currentValue.isEmpty) return null;
    return options.contains(currentValue) ? currentValue : null;
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> options) {
    return options
        .map((value) => DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    final makes = _bicycleMeta?.makes.map((e) => e.name).toList() ?? [];
    final models = _bicycleMeta?.models.map((e) => e.name).toList() ?? [];
    final conditions = _bicycleMeta?.conditionStatus.map((e) => e.name).toList() ?? [];
    final types = _bicycleMeta?.types.map((e) => e.name).toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.bicycle == null ? 'Add Bicycle' : 'Edit Bicycle',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
        actions: [
          if (widget.bicycle != null) // Show delete button only for existing bicycles
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: const Icon(Icons.save, color:Color(0xFF4CAF50)),
            onPressed: _saveBicycle,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildStyledTextFormField(
                  initialValue: _currentBicycle.name,
                  labelText: 'Name',
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => _currentBicycle = _currentBicycle.copyWith(name: value ?? ''),
                ),
                const SizedBox(height: 20),

                _buildStyledDropdown(
                  value: _selectedMake,
                  items: _buildDropdownItems(makes),
                  onChanged: (value) => setState(() => _selectedMake = value),
                  labelText: 'Make',
                  validator: (value) => value == null ? 'Please select a make' : null,
                ),
                const SizedBox(height: 20),

                _buildStyledDropdown(
                  value: _selectedModel,
                  items: _buildDropdownItems(models),
                  onChanged: (value) => setState(() => _selectedModel = value),
                  labelText: 'Model',
                  validator: (value) => value == null ? 'Please select a model' : null,
                ),
                const SizedBox(height: 20),

                _buildStyledDropdown(
                  value: _selectedType,
                  items: _buildDropdownItems(types),
                  onChanged: (value) => setState(() => _selectedType = value),
                  labelText: 'Type',
                  validator: (value) => value == null ? 'Please select a type' : null,
                ),
                const SizedBox(height: 20),

                _buildStyledDropdown(
                  value: _selectedCondition,
                  items: _buildDropdownItems(conditions),
                  onChanged: (value) => setState(() => _selectedCondition = value),
                  labelText: 'Condition',
                  validator: (value) => value == null ? 'Please select condition' : null,
                ),
                const SizedBox(height: 20),

                _buildStyledTextFormField(
                  initialValue: _currentBicycle.location,
                  labelText: 'Location',
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => _currentBicycle = _currentBicycle.copyWith(location: value ?? ''),
                ),
                const SizedBox(height: 20),

                _buildStyledTextFormField(
                  initialValue: _currentBicycle.pricePerHour.toString(),
                  labelText: 'Price per Hour',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (value) => _currentBicycle = _currentBicycle.copyWith(
                    pricePerHour: double.parse(value ?? '0'),
                  ),
                ),
                const SizedBox(height: 20),

                _buildStyledTextFormField(
                  initialValue: _currentBicycle.makeYear.toString(),
                  labelText: 'Make Year',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Invalid year';
                    return null;
                  },
                  onSaved: (value) => setState(() {
                    _selectedMakeYear = int.parse(value ?? '${DateTime.now().year}');
                  }),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _saveBicycle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Color(0xFF4CAF50).withOpacity(0.5),
                  ),
                  child: const Text(
                    'Save Bicycle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStyledTextFormField({
    required String? initialValue,
    required String labelText,
    required String? Function(String?)? validator,
    required void Function(String?)? onSaved,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.tealAccent,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildStyledDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required String labelText,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.grey[900],
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      validator: validator,
    );
  }

  void _saveBicycle() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      _currentBicycle = _currentBicycle.copyWith(
        types: _selectedType ?? '',
        condition: _selectedCondition ?? 'Good',
        makeName: _selectedMake ?? '',
        modelName: _selectedModel ?? '',
        makeYear: _selectedMakeYear ?? DateTime.now().year,
      );
      
      Navigator.pop(context, _currentBicycle);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Bicycle',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${_currentBicycle.fullName}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
                Navigator.of(context).pop(true); // Return true to indicate deletion
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}