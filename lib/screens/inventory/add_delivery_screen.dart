import 'package:flutter/material.dart';
import '../../models/delivery.dart';
import '../../data/dummy_data.dart';
import 'package:intl/intl.dart';

class AddDeliveryScreen extends StatefulWidget {
  final Delivery? delivery;

  const AddDeliveryScreen({super.key, this.delivery});

  @override
  State<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _salesOrderController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _carrierController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? selectedCustomerId;
  String selectedCustomerName = '';
  String? selectedSourceLocationId;
  String selectedSourceLocationName = '';
  DateTime deliveryDate = DateTime.now();
  String selectedStatus = 'draft';
  
  List<DeliveryLine> deliveryLines = [];
  
  final List<String> statusOptions = ['draft', 'ready', 'done', 'cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.delivery != null) {
      _loadDeliveryData();
    } else {
      _generateDeliveryNumber();
    }
  }

  void _loadDeliveryData() {
    final delivery = widget.delivery!;
    _numberController.text = delivery.number;
    _salesOrderController.text = delivery.salesOrderId;
    _destinationAddressController.text = delivery.destinationAddress;
    _trackingNumberController.text = delivery.trackingNumber;
    _carrierController.text = delivery.carrier;
    _notesController.text = delivery.notes;
    selectedCustomerId = delivery.customerId;
    selectedCustomerName = delivery.customerName;
    selectedSourceLocationId = delivery.sourceLocationId;
    selectedSourceLocationName = delivery.sourceLocationName;
    deliveryDate = delivery.deliveryDate;
    selectedStatus = delivery.status;
    deliveryLines = List.from(delivery.lines);
  }

  void _generateDeliveryNumber() {
    final now = DateTime.now();
    _numberController.text = 'WH/OUT/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.delivery == null ? 'Add Delivery' : 'Edit Delivery'),
        actions: [
          TextButton(
            onPressed: _saveDelivery,
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
                        'Delivery Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCustomerSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _salesOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Sales Order',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location and Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location & Date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSourceLocationSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _destinationAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Destination Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Delivery Date',
                              deliveryDate,
                              (date) => setState(() => deliveryDate = date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.toUpperCase()),
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

              // Shipping Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _carrierController,
                              decoration: const InputDecoration(
                                labelText: 'Carrier',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _trackingNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Tracking Number',
                                border: OutlineInputBorder(),
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

              // Delivery Lines
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Lines',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addDeliveryLine,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Line'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (deliveryLines.isEmpty)
                        const Center(
                          child: Text('No delivery lines added yet'),
                        )
                      else
                        ...deliveryLines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                          return _buildDeliveryLineCard(line, index);
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
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

  Widget _buildCustomerSelector() {
    return InkWell(
      onTap: _selectCustomer,
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
                    'Customer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedCustomerName.isEmpty ? 'Select Customer' : selectedCustomerName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedCustomerName.isEmpty ? Colors.grey : Colors.black,
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

  Widget _buildSourceLocationSelector() {
    return InkWell(
      onTap: _selectSourceLocation,
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
                    'Source Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedSourceLocationName.isEmpty ? 'Select Source Location' : selectedSourceLocationName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedSourceLocationName.isEmpty ? Colors.grey : Colors.black,
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
    );
  }

  Widget _buildDeliveryLineCard(DeliveryLine line, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    line.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDeliveryLine(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Ordered: ${line.quantityOrdered.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: Text('Delivered: ${line.quantityDelivered.toStringAsFixed(0)}'),
                ),
              ],
            ),
            if (line.serialNumbers.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Serial: ${line.serialNumbers}'),
            ],
          ],
        ),
      ),
    );
  }

  void _selectCustomer() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Customer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.customers.length,
                  itemBuilder: (context, index) {
                    final customer = DummyData.customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text(customer.email),
                      onTap: () {
                        setState(() {
                          selectedCustomerId = customer.id;
                          selectedCustomerName = customer.name;
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

  void _selectSourceLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Source Location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.locations.length,
                  itemBuilder: (context, index) {
                    final location = DummyData.locations[index];
                    return ListTile(
                      title: Text(location.name),
                      subtitle: Text(location.completeAddress),
                      onTap: () {
                        setState(() {
                          selectedSourceLocationId = location.id;
                          selectedSourceLocationName = location.name;
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

  void _addDeliveryLine() {
    showDialog(
      context: context,
      builder: (context) => _DeliveryLineDialog(
        onSave: (line) {
          setState(() {
            deliveryLines.add(line);
          });
        },
      ),
    );
  }

  void _removeDeliveryLine(int index) {
    setState(() {
      deliveryLines.removeAt(index);
    });
  }

  void _saveDelivery() {
    if (_formKey.currentState!.validate()) {
      if (selectedCustomerId == null || selectedSourceLocationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select customer and source location')),
        );
        return;
      }

      final delivery = Delivery(
        id: widget.delivery?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text,
        customerId: selectedCustomerId!,
        customerName: selectedCustomerName,
        salesOrderId: _salesOrderController.text,
        deliveryDate: deliveryDate,
        status: selectedStatus,
        sourceLocationId: selectedSourceLocationId!,
        sourceLocationName: selectedSourceLocationName,
        destinationAddress: _destinationAddressController.text,
        lines: deliveryLines,
        trackingNumber: _trackingNumberController.text,
        carrier: _carrierController.text,
        notes: _notesController.text,
        createdAt: widget.delivery?.createdAt ?? DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, delivery);
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _salesOrderController.dispose();
    _destinationAddressController.dispose();
    _trackingNumberController.dispose();
    _carrierController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _DeliveryLineDialog extends StatefulWidget {
  final Function(DeliveryLine) onSave;

  const _DeliveryLineDialog({required this.onSave});

  @override
  State<_DeliveryLineDialog> createState() => _DeliveryLineDialogState();
}

class _DeliveryLineDialogState extends State<_DeliveryLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityOrderedController = TextEditingController(text: '1');
  final _quantityDeliveredController = TextEditingController(text: '1');
  final _serialNumbersController = TextEditingController();

  String? selectedProductId;
  String selectedProductName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Delivery Line'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProductSelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityOrderedController,
                      decoration: const InputDecoration(
                        labelText: 'Qty Ordered',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityDeliveredController,
                      decoration: const InputDecoration(
                        labelText: 'Qty Delivered',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumbersController,
                decoration: const InputDecoration(
                  labelText: 'Serial Numbers',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveLine,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildProductSelector() {
    return InkWell(
      onTap: _selectProduct,
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
                    'Product',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedProductName.isEmpty ? 'Select Product' : selectedProductName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedProductName.isEmpty ? Colors.grey : Colors.black,
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

  void _selectProduct() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.products.length,
                  itemBuilder: (context, index) {
                    final product = DummyData.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('SKU: ${product.defaultCode}'),
                      onTap: () {
                        setState(() {
                          selectedProductId = product.id;
                          selectedProductName = product.name;
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

  void _saveLine() {
    if (_formKey.currentState!.validate()) {
      if (selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      final line = DeliveryLine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: selectedProductId!,
        productName: selectedProductName,
        quantityOrdered: double.parse(_quantityOrderedController.text),
        quantityDelivered: double.parse(_quantityDeliveredController.text),
        serialNumbers: _serialNumbersController.text,
      );

      widget.onSave(line);
      Navigator.pop(context);
    }
  }
}