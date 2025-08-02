import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../data/dummy_data.dart';
import 'package:intl/intl.dart';

class AddPaymentScreen extends StatefulWidget {
  final Payment? payment;

  const AddPaymentScreen({super.key, this.payment});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  String? selectedPartnerId;
  String selectedPartnerName = '';
  DateTime paymentDate = DateTime.now();
  String selectedPaymentType = 'inbound';
  String selectedPaymentMethod = 'Manual';
  String selectedState = 'draft';

  final List<String> paymentTypes = ['inbound', 'outbound'];
  final List<String> paymentMethods = ['Manual', 'Bank Transfer', 'Credit Card', 'Cash', 'Check'];
  final List<String> states = ['draft', 'posted', 'sent', 'reconciled', 'cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _loadPaymentData();
    } else {
      _generateReference();
    }
  }

  void _loadPaymentData() {
    final payment = widget.payment!;
    _referenceController.text = payment.reference;
    _amountController.text = payment.amount.toString();
    _memoController.text = payment.memo;
    selectedPartnerId = payment.partnerId;
    selectedPartnerName = payment.partnerName;
    paymentDate = payment.paymentDate;
    selectedPaymentType = payment.paymentType;
    selectedPaymentMethod = payment.paymentMethod;
    selectedState = payment.state;
  }

  void _generateReference() {
    final now = DateTime.now();
    _referenceController.text = 'PAY/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment == null ? 'Add Payment' : 'Edit Payment'),
        actions: [
          TextButton(
            onPressed: _savePayment,
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
                        'Payment Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter reference';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedPaymentType,
                              decoration: const InputDecoration(
                                labelText: 'Payment Type',
                                border: OutlineInputBorder(),
                              ),
                              items: paymentTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPartnerSelector(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        'Payment Date',
                        paymentDate,
                            (date) => setState(() => paymentDate = date),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedPaymentMethod,
                              decoration: const InputDecoration(
                                labelText: 'Payment Method',
                                border: OutlineInputBorder(),
                              ),
                              items: paymentMethods.map((method) {
                                return DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedState,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(),
                              ),
                              items: states.map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedState = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _memoController,
                        decoration: const InputDecoration(
                          labelText: 'Memo',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
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

  Widget _buildPartnerSelector() {
    return InkWell(
      onTap: _selectPartner,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPaymentType == 'inbound' ? 'Customer' : 'Vendor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedPartnerName.isEmpty ? 'Select Partner' : selectedPartnerName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedPartnerName.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _selectPartner() {
    final partners = selectedPaymentType == 'inbound'
        ? DummyData.customers
        : DummyData.customers; // In real app, would be vendors

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select ${selectedPaymentType == 'inbound' ? 'Customer' : 'Vendor'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final partner = partners[index];
                    return ListTile(
                      title: Text(partner.name),
                      subtitle: Text(partner.email),
                      onTap: () {
                        setState(() {
                          selectedPartnerId = partner.id;
                          selectedPartnerName = partner.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      if (selectedPartnerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a ${selectedPaymentType == 'inbound' ? 'customer' : 'vendor'}')),
        );
        return;
      }

      final payment = Payment(
        id: widget.payment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        reference: _referenceController.text,
        invoiceId: '',
        invoiceNumber: '',
        customerId: selectedPartnerId!,
        customerName: selectedPartnerName,
        partnerId: selectedPartnerId!,
        partnerName: selectedPartnerName,
        amount: double.parse(_amountController.text),
        paymentDate: paymentDate,
        paymentType: selectedPaymentType,
        paymentMethod: selectedPaymentMethod,
        status: selectedState,
        state: selectedState,
        memo: _memoController.text,
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, payment);
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }
}