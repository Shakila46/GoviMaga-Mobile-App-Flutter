import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/crop_service.dart';

class AddCropScreen extends StatefulWidget {
  final String language;
  final Map<String, dynamic>? cropToEdit;
  
  const AddCropScreen({super.key, required this.language, this.cropToEdit});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final CropService _cropService = CropService();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCrop;
  final TextEditingController _varietyController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _cropTypes = [
    'Paddy',
    'Tomato',
    'Chili',
    'Pumpkin',
    'Onion',
    'Carrot',
    'Cabbage',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cropToEdit != null) {
      _selectedCrop = widget.cropToEdit!['name'];
      if (!_cropTypes.contains(_selectedCrop)) {
        if (_selectedCrop != null && _selectedCrop!.isNotEmpty) {
          _cropTypes.add(_selectedCrop!);
        } else {
          _selectedCrop = null;
        }
      }
      _varietyController.text = widget.cropToEdit!['variety'] ?? '';
      
      final timestamp = widget.cropToEdit!['plantedDate'];
      if (timestamp != null) {
        _selectedDate = timestamp.toDate();
      }
    }
  }

  @override
  void dispose() {
    _varietyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.cropToEdit != null) {
        await _cropService.updateCrop(
          cropId: widget.cropToEdit!['id'],
          name: _selectedCrop!,
          variety: _varietyController.text.trim(),
          plantedDate: _selectedDate,
        );
      } else {
        await _cropService.addCrop(
          name: _selectedCrop!,
          variety: _varietyController.text.trim(),
          plantedDate: _selectedDate,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/app_logo.jpeg'),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(widget.cropToEdit != null ? 'Edit Crop' : 'Add New Crop'),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCrop,
                      decoration: const InputDecoration(
                        labelText: 'Crop Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _cropTypes.map((crop) {
                        return DropdownMenuItem(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCrop = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a crop' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _varietyController,
                      decoration: const InputDecoration(
                        labelText: 'Variety (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Planted Date'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(widget.cropToEdit != null ? 'Save Changes' : 'Add Crop'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
