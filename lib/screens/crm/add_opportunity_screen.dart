import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/opportunity.dart';
import '../../models/customer.dart';


import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html_parser;
import '../../services/crm_service.dart';


class AddOpportunityScreen extends StatefulWidget {
  final Opportunity? opportunity;

  const AddOpportunityScreen({super.key, this.opportunity});

  @override
  State<AddOpportunityScreen> createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  String _stripHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }
  // Removed duplicate _fetchCustomers method
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _expectedRevenueController = TextEditingController();
  final _probabilityController = TextEditingController();
  final _salesPersonController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _campaignController = TextEditingController();
  final _mediumController = TextEditingController();
  final _sourceController = TextEditingController();
  final _referredByController = TextEditingController();
  final _jobPositionController = TextEditingController();
  final _mobileController = TextEditingController();
  final _companyController = TextEditingController();
  final _salesTeamController = TextEditingController();
  final _daysToAssignController = TextEditingController();
  final _daysToCloseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priorityController = TextEditingController();
  final _typeController = TextEditingController();
  final _functionController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  
  Customer? _selectedCustomer;
  List<Customer> _customerList = [];
  bool _isLoadingCustomers = false;
  String _selectedStage = 'qualified';
  DateTime _expectedCloseDate = DateTime.now().add(const Duration(days: 30));
  
  final List<String> _stageOptions = ['qualified', 'proposition', 'negotiation', 'won', 'lost'];

  @override
  void initState() {
    super.initState();
    _fetchCustomers().then((_) {
      if (widget.opportunity != null) {
        _populateFields();
      }
    });
  }

  void _populateFields() {
    final opportunity = widget.opportunity!;
    _titleController.text = opportunity.title;
    _expectedRevenueController.text = opportunity.expectedRevenue.toString();
    _probabilityController.text = opportunity.probability.toString();
    _salesPersonController.text = opportunity.salesPerson;
    _descriptionController.text = opportunity.description;
    // Ensure stage is valid for DropdownButton
    if (_stageOptions.contains(opportunity.stage)) {
      _selectedStage = opportunity.stage;
    } else {
      _selectedStage = _stageOptions.first;
    }
    _expectedCloseDate = opportunity.expectedCloseDate;
    _campaignController.text = opportunity.campaign;
    _mediumController.text = opportunity.medium;
    _sourceController.text = opportunity.source;
    _referredByController.text = opportunity.referredBy;
    _jobPositionController.text = opportunity.jobPosition;
    _mobileController.text = opportunity.mobile;
    _companyController.text = opportunity.company;
    _salesTeamController.text = opportunity.salesTeam;
    _daysToAssignController.text = opportunity.daysToAssign.toString();
    _daysToCloseController.text = opportunity.daysToClose.toString();
    _emailController.text = opportunity.email;
    _phoneController.text = opportunity.phone;
    _priorityController.text = opportunity.priority;
    _typeController.text = opportunity.type;
    _functionController.text = opportunity.function;
    _cityController.text = opportunity.city;
    _stateNameController.text = opportunity.stateName;
    _countryController.text = opportunity.country;
    _zipCodeController.text = opportunity.zipCode;
    _websiteController.text = opportunity.website;
    _industryController.text = opportunity.industry;
    
    // Find and pre-select the customer
    if (_customerList.isEmpty) {
      _selectedCustomer = null;
    } else {
      try {
        _selectedCustomer = _customerList.firstWhere(
          (c) => c.id == widget.opportunity!.customerId,
        );
      } catch (e) {
        _selectedCustomer = _customerList.first;
      }
    }
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });
    try {
      final crmService = CrmService();
      final customers = await crmService.getCustomers(customerType: 'company');
      setState(() {
        _customerList = customers;
      });
    } catch (e) {
      // Optionally handle error
    } finally {
      setState(() {
        _isLoadingCustomers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.opportunity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editOpportunity : l10n.addOpportunity),
        actions: [
          TextButton(
            onPressed: _saveOpportunity,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.opportunityDetails,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: l10n.title + ' *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _isLoadingCustomers
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<Customer>(
                              value: _selectedCustomer,
                              decoration: InputDecoration(
                                labelText: l10n.customer + ' *',
                                border: const OutlineInputBorder(),
                              ),
                              items: _customerList
                                  .map((customer) => DropdownMenuItem<Customer>(
                                        value: customer,
                                        child: SizedBox(
                                          width: 220,
                                          child: Text(
                                            customer.parentName != null && customer.parentName!.isNotEmpty
                                                ? '${customer.name} (${customer.parentName})'
                                                : customer.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCustomer = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return l10n.pleaseSelectCustomer;
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expectedRevenueController,
                              decoration: InputDecoration(
                                labelText: l10n.expectedRevenue + ' *',
                                border: const OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.required;
                                }
                                if (double.tryParse(value) == null) {
                                  return l10n.invalidNumber;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _probabilityController,
                              decoration: InputDecoration(
                                labelText: l10n.probability + ' *',
                                border: const OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.required;
                                }
                                final prob = int.tryParse(value);
                                if (prob == null || prob < 0 || prob > 100) {
                                  return 'Enter 0-100';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStage,
                        decoration: InputDecoration(
                          labelText: l10n.stage,
                          border: const OutlineInputBorder(),
                        ),
                        items: _stageOptions.map((stage) {
                          return DropdownMenuItem(
                            value: stage,
                            child: Text(stage.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStage = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _salesPersonController,
                        decoration: InputDecoration(
                          labelText: l10n.salesPerson + ' *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(l10n.expectedCloseDate),
                        subtitle: Text(DateFormat('MMM dd, yyyy').format(_expectedCloseDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      if (_descriptionController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _stripHtml(_descriptionController.text),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ExpansionTile(
                        title: Text(l10n.moreDetails),
                        initiallyExpanded: true,
                        children: [
                          TextFormField(
                            controller: _campaignController,
                            decoration: InputDecoration(labelText: l10n.campaign, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _mediumController,
                            decoration: InputDecoration(labelText: l10n.medium, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _sourceController,
                            decoration: InputDecoration(labelText: l10n.source, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _referredByController,
                            decoration: InputDecoration(labelText: l10n.referredBy, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _jobPositionController,
                            decoration: InputDecoration(labelText: l10n.jobPosition, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _mobileController,
                            decoration: InputDecoration(labelText: l10n.mobile, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _companyController,
                            decoration: InputDecoration(labelText: l10n.company, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _salesTeamController,
                            decoration: InputDecoration(labelText: l10n.salesTeam, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _daysToAssignController,
                            decoration: InputDecoration(labelText: l10n.daysToAssign, border: const OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _daysToCloseController,
                            decoration: InputDecoration(labelText: l10n.daysToClose, border: const OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: l10n.email, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priorityController,
                            decoration: InputDecoration(labelText: l10n.priority, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _typeController,
                            decoration: InputDecoration(labelText: l10n.type, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _functionController,
                            decoration: InputDecoration(labelText: l10n.function, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(labelText: l10n.city, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stateNameController,
                            decoration: InputDecoration(labelText: l10n.state, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _countryController,
                            decoration: InputDecoration(labelText: l10n.country, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _zipCodeController,
                            decoration: InputDecoration(labelText: l10n.zipCode, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _websiteController,
                            decoration: InputDecoration(labelText: l10n.website, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _industryController,
                            decoration: InputDecoration(labelText: l10n.industry, border: const OutlineInputBorder()),
                          ),
                        ],
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedCloseDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _expectedCloseDate) {
      setState(() {
        _expectedCloseDate = picked;
      });
    }
  }

  void _saveOpportunity() {
    if (_formKey.currentState!.validate()) {
      final opportunity = Opportunity(
        id: widget.opportunity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        expectedRevenue: double.parse(_expectedRevenueController.text),
        probability: int.parse(_probabilityController.text),
        stage: _selectedStage,
        state: 'open',
        expectedCloseDate: _expectedCloseDate,
        salesPerson: _salesPersonController.text,
        description: _descriptionController.text,
        createdAt: widget.opportunity?.createdAt ?? DateTime.now(),
        tags: widget.opportunity?.tags ?? <String>[],
        campaign: _campaignController.text,
        medium: _mediumController.text,
        source: _sourceController.text,
        referredBy: _referredByController.text,
        jobPosition: _jobPositionController.text,
        mobile: _mobileController.text,
        company: _companyController.text,
        salesTeam: _salesTeamController.text,
        daysToAssign: int.tryParse(_daysToAssignController.text) ?? 0,
        daysToClose: int.tryParse(_daysToCloseController.text) ?? 0,
        email: _emailController.text,
        phone: _phoneController.text,
        priority: _priorityController.text,
        type: _typeController.text,
        function: _functionController.text,
        city: _cityController.text,
        stateName: _stateNameController.text,
        country: _countryController.text,
        zipCode: _zipCodeController.text,
        website: _websiteController.text,
        industry: _industryController.text,
      );

      // Save to Odoo API
      final crmService = CrmService();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final Future<Opportunity> saveFuture =
          widget.opportunity == null
              ? crmService.createOpportunity(opportunity)
              : crmService.updateOpportunity(opportunity);
      saveFuture.then((savedOpportunity) {
        Navigator.of(context).pop(); // Remove loading dialog
        Navigator.pop(context, savedOpportunity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.opportunity == null ? 'Opportunity added successfully' : 'Opportunity updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((e) {
        Navigator.of(context).pop(); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save opportunity to Odoo'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _expectedRevenueController.dispose();
    _probabilityController.dispose();
    _salesPersonController.dispose();
    _descriptionController.dispose();
    _campaignController.dispose();
    _mediumController.dispose();
    _sourceController.dispose();
    _referredByController.dispose();
    _jobPositionController.dispose();
    _mobileController.dispose();
    _companyController.dispose();
    _salesTeamController.dispose();
    _daysToAssignController.dispose();
    _daysToCloseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _priorityController.dispose();
    _typeController.dispose();
    _functionController.dispose();
    _cityController.dispose();
    _stateNameController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    super.dispose();
  }
}