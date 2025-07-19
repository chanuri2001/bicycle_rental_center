import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/bicycle.dart';
import '../../models/bike_type.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEditBicycleScreen extends StatefulWidget {
  final Bicycle? bicycle;

  const AddEditBicycleScreen({super.key, this.bicycle});

  @override
  State<AddEditBicycleScreen> createState() => _AddEditBicycleScreenState();
}

class _AddEditBicycleScreenState extends State<AddEditBicycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _totalCountController = TextEditingController();
  final _availableCountController = TextEditingController();

  BikeType _selectedType = BikeType.mountain;
  String _selectedCondition = 'Good';
  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  final List<String> _conditions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
    'Needs Repair'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bicycle != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final bicycle = widget.bicycle!;
    _nameController.text = bicycle.name;
    _brandController.text = bicycle.brand;
    _descriptionController.text = bicycle.description;
    _priceController.text = bicycle.pricePerHour.toString();
    _locationController.text = bicycle.location;
    _totalCountController.text = bicycle.totalCount.toString();
    _availableCountController.text = bicycle.availableCount.toString();
    _selectedType = bicycle.type;
    _selectedCondition = bicycle.condition;
    _imageUrl = bicycle.imageUrl;
    _selectedImage = bicycle.imageFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _totalCountController.dispose();
    _availableCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Select Image Source',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.success,
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.success,
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
            _imageUrl = null;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', AppColors.danger);
    }
  }

  Future<void> _saveBicycle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final totalCount = int.parse(_totalCountController.text);
      final availableCount = int.parse(_availableCountController.text);
      
      final bicycle = Bicycle(
        id: widget.bicycle?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        type: _selectedType,
        location: _locationController.text.trim(),
        pricePerHour: double.parse(_priceController.text),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrl,
        imageFile: _selectedImage,
        condition: _selectedCondition,
        totalCount: totalCount,
        availableCount: availableCount,
        rentedCount: totalCount - availableCount,
      );

      Navigator.of(context).pop(bicycle);
    } catch (e) {
      _showSnackBar('Failed to save bicycle: $e', AppColors.danger);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bicycle != null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Bicycle' : 'Add New Bicycle',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBicycle,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? AppColors.textSecondary : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bicycle Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Bicycle Model Name',
                  prefixIcon: Icon(
                    Icons.directions_bike,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter bicycle model name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  prefixIcon: Icon(
                    Icons.branding_watermark,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BikeType>(
                value: _selectedType,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Bicycle Type',
                  prefixIcon: Icon(
                    Icons.category,
                    color: AppColors.textSecondary,
                  ),
                ),
                dropdownColor: AppColors.cardBackground,
                items: BikeType.values.map((type) {
                  return DropdownMenuItem<BikeType>(
                    value: type,
                    child: Text(
                      type.displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(
                    Icons.description,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pricing & Inventory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per Hour (\$)',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter price';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalCountController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Count',
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter total count';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _availableCountController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available Count',
                        prefixIcon: Icon(
                          Icons.check_circle,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter available count';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Enter valid number';
                        }
                        final total = int.tryParse(_totalCountController.text) ?? 0;
                        if (int.parse(value) > total) {
                          return 'Cannot exceed total count';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: Icon(
                    Icons.star,
                    color: AppColors.textSecondary,
                  ),
                ),
                dropdownColor: AppColors.cardBackground,
                items: _conditions.map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(
                      condition,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBicycle,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Bicycle' : 'Add Bicycle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: AppColors.textSecondary),
        SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}