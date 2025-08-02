import 'package:flutter/material.dart';
import '../../models/location.dart';

class AddLocationScreen extends StatefulWidget {
  final Location? location;

  const AddLocationScreen({super.key, this.location});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _addressController = TextEditingController();

  String selectedUsage = 'internal';
  bool isScrapLocation = false;
  bool isReturnLocation = false;
  bool isActive = true;

  final List<String> usageOptions = ['internal', 'customer', 'supplier', 'transit'];

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _loadLocationData();
    }
  }

  void _loadLocationData() {
    final location = widget.location!;
    _nameController.text = location.name;
    _barcodeController.text = location.barcode;
    _addressController.text = location.completeAddress;
    selectedUsage = location.usage;
    isScrapLocation = location.isScrapLocation;
    isReturnLocation = location.isReturnLocation;
    isActive = location.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location == null ? 'Add Location' : 'Edit Location'),
        actions: [
          TextButton(
            onPressed: _saveLocation,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Location Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Barcode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedUsage,
                        decoration: const InputDecoration(
                          labelText: 'Location Type',
                          border: OutlineInputBorder(),
                        ),
                        items: usageOptions.map((usage) {
                          return DropdownMenuItem(
                            value: usage,
                            child: Text(usage.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUsage = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Address Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Complete Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Options',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Is Active'),
                        subtitle: const Text('Location is currently active'),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Is Scrap Location'),
                        subtitle: const Text('Products sent here are considered scrapped'),
                        value: isScrapLocation,
                        onChanged: (value) {
                          setState(() {
                            isScrapLocation = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Is Return Location'),
                        subtitle: const Text('Location for returned products'),
                        value: isReturnLocation,
                        onChanged: (value) {
                          setState(() {
                            isReturnLocation = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final location = Location(
        id: widget.location?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: selectedUsage,
        address: _addressController.text,
        completeAddress: _addressController.text,
        usage: selectedUsage,
        barcode: _barcodeController.text,
        isActive: isActive,
        isScrapLocation: isScrapLocation,
        isReturnLocation: isReturnLocation,
        parentLocationId: widget.location?.parentLocationId ?? '',
        createdAt: widget.location?.createdAt ?? DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, location);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}