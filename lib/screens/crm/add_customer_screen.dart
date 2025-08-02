import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../services/crm_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _crmService = CrmService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();

  String selectedCustomerType = 'company';
  String selectedStatus = 'active';
  bool isActive = true;

  final List<String> customerTypes = ['company', 'individual'];
  final List<String> statusOptions = ['active', 'inactive', 'prospect'];

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _loadCustomerData();
    }
  }

  void _loadCustomerData() {
    final customer = widget.customer!;
    _nameController.text = customer.name;
    _emailController.text = customer.email;
    _phoneController.text = customer.phone;
    _addressController.text = customer.address;
    _cityController.text = customer.city;
    _stateController.text = customer.state;
    _countryController.text = customer.country;
    _zipCodeController.text = customer.zipCode;
    _websiteController.text = customer.website;
    _industryController.text = customer.industry;
    selectedCustomerType = customer.customerType;
    selectedStatus = customer.status;
    isActive = customer.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? l10n.addCustomer : l10n.editCustomer),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: _saveCustomer,
              child: Text(l10n.save),
            ),
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
                        l10n.basicInformation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.customerName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterEmail;
                                }
                                if (!value.contains('@')) {
                                  return l10n.pleaseEnterValidEmail;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: l10n.phone,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCustomerType,
                              decoration: InputDecoration(
                                labelText: l10n.customerType,
                                border: const OutlineInputBorder(),
                              ),
                              items: customerTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type == 'company' ? l10n.company : l10n.individual),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCustomerType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedStatus,
                              decoration: InputDecoration(
                                labelText: l10n.status,
                                border: const OutlineInputBorder(),
                              ),
                              items: statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status == 'active'
                                        ? l10n.active
                                        : status == 'inactive'
                                            ? l10n.inactive
                                            : l10n.prospect,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
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
                        l10n.addressInformation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: l10n.address,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: l10n.city,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: InputDecoration(
                                labelText: l10n.state,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              decoration: InputDecoration(
                                labelText: l10n.country,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              decoration: InputDecoration(
                                labelText: l10n.zipCode,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.additionalInformation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _websiteController,
                              decoration: InputDecoration(
                                labelText: l10n.website,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _industryController,
                              decoration: InputDecoration(
                                labelText: l10n.industry,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(l10n.activeCustomer),
                        subtitle: Text(l10n.customerIsCurrentlyActive),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
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

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.customer != null;
      final customer = Customer(
        id: isEditing ? widget.customer!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        zipCode: _zipCodeController.text,
        website: _websiteController.text,
        industry: _industryController.text,
        customerType: selectedCustomerType,
        isActive: isActive,
        status: selectedStatus,
        createdAt: isEditing ? widget.customer!.createdAt : DateTime.now(),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      // Debug print to verify ID before update
      debugPrint('Saving customer with id: \\${customer.id} (isEditing: \\${isEditing})');
      final future = isEditing
          ? _crmService.updateCustomer(customer)
          : _crmService.createCustomer(customer);
      future.then((resultCustomer) {
        Navigator.pop(context); // Remove loading dialog
        Navigator.pop(context, resultCustomer);
      }).catchError((e) {
        Navigator.pop(context); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).failed}: ${e.toString()}')),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    super.dispose();
  }
}