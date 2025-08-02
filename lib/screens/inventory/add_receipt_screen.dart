import 'package:flutter/material.dart';
import '../../models/receipt.dart';
import '../../data/dummy_data.dart';
import 'package:intl/intl.dart';

class AddReceiptScreen extends StatefulWidget {
  final Receipt? receipt;

  const AddReceiptScreen({super.key, this.receipt});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _purchaseOrderController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? selectedSupplierId;
  String selectedSupplierName = '';
  String? selectedLocationId;
  String selectedLocationName = '';
  DateTime receiptDate = DateTime.now();
  String selectedStatus = 'draft';
  
  List<ReceiptLine> receiptLines = [];
  
  final List<String> statusOptions = ['draft', 'done', 'cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.receipt != null) {
      _loadReceiptData();
    } else {
      _generateReceiptNumber();
    }
  }

  void _loadReceiptData() {
    final receipt = widget.receipt!;
    _numberController.text = receipt.number;
    _purchaseOrderController.text = receipt.purchaseOrderId;
    _notesController.text = receipt.notes;
    selectedSupplierId = receipt.supplierId;
    selectedSupplierName = receipt.supplierName;
    selectedLocationId = receipt.locationId;
    selectedLocationName = receipt.locationName;
    receiptDate = receipt.receiptDate;
    selectedStatus = receipt.status;
    receiptLines = List.from(receipt.lines);
  }

  void _generateReceiptNumber() {
    final now = DateTime.now();
    _numberController.text = 'WH/IN/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receipt == null ? 'Add Receipt' : 'Edit Receipt'),
        actions: [
          TextButton(
            onPressed: _saveReceipt,
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
                        'Receipt Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Receipt Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter receipt number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSupplierSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _purchaseOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Order',
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
                      _buildLocationSelector(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Receipt Date',
                              receiptDate,
                              (date) => setState(() => receiptDate = date),
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

              // Receipt Lines
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
                            'Receipt Lines',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addReceiptLine,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Line'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (receiptLines.isEmpty)
                        const Center(
                          child: Text('No receipt lines added yet'),
                        )
                      else
                        ...receiptLines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                          return _buildReceiptLineCard(line, index);
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

  Widget _buildSupplierSelector() {
    return InkWell(
      onTap: _selectSupplier,
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
                    'Supplier',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedSupplierName.isEmpty ? 'Select Supplier' : selectedSupplierName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedSupplierName.isEmpty ? Colors.grey : Colors.black,
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

  Widget _buildLocationSelector() {
    return InkWell(
      onTap: _selectLocation,
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
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedLocationName.isEmpty ? 'Select Location' : selectedLocationName,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLocationName.isEmpty ? Colors.grey : Colors.black,
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

  Widget _buildReceiptLineCard(ReceiptLine line, int index) {
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
                  onPressed: () => _removeReceiptLine(index),
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
                  child: Text('Received: ${line.quantityReceived.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: Text('Cost: ${NumberFormat.currency(symbol: '\$').format(line.unitCost)}'),
                ),
              ],
            ),
            if (line.lotNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Lot: ${line.lotNumber}'),
            ],
          ],
        ),
      ),
    );
  }

  void _selectSupplier() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Supplier',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.customers.length, // Using customers as suppliers for demo
                  itemBuilder: (context, index) {
                    final supplier = DummyData.customers[index];
                    return ListTile(
                      title: Text(supplier.name),
                      subtitle: Text(supplier.email),
                      onTap: () {
                        setState(() {
                          selectedSupplierId = supplier.id;
                          selectedSupplierName = supplier.name;
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

  void _selectLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Location',
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
                          selectedLocationId = location.id;
                          selectedLocationName = location.name;
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

  void _addReceiptLine() {
    showDialog(
      context: context,
      builder: (context) => _ReceiptLineDialog(
        onSave: (line) {
          setState(() {
            receiptLines.add(line);
          });
        },
      ),
    );
  }

  void _removeReceiptLine(int index) {
    setState(() {
      receiptLines.removeAt(index);
    });
  }

  void _saveReceipt() {
    if (_formKey.currentState!.validate()) {
      if (selectedSupplierId == null || selectedLocationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select supplier and location')),
        );
        return;
      }

      final receipt = Receipt(
        id: widget.receipt?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text,
        supplierId: selectedSupplierId!,
        supplierName: selectedSupplierName,
        purchaseOrderId: _purchaseOrderController.text,
        receiptDate: receiptDate,
        status: selectedStatus,
        locationId: selectedLocationId!,
        locationName: selectedLocationName,
        lines: receiptLines,
        notes: _notesController.text,
        createdAt: widget.receipt?.createdAt ?? DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, receipt);
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _purchaseOrderController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _ReceiptLineDialog extends StatefulWidget {
  final Function(ReceiptLine) onSave;

  const _ReceiptLineDialog({required this.onSave});

  @override
  State<_ReceiptLineDialog> createState() => _ReceiptLineDialogState();
}

class _ReceiptLineDialogState extends State<_ReceiptLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityOrderedController = TextEditingController(text: '1');
  final _quantityReceivedController = TextEditingController(text: '1');
  final _unitCostController = TextEditingController();
  final _lotNumberController = TextEditingController();

  String? selectedProductId;
  String selectedProductName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Receipt Line'),
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
                      controller: _quantityReceivedController,
                      decoration: const InputDecoration(
                        labelText: 'Qty Received',
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitCostController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Cost',
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
                      controller: _lotNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Lot Number',
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
                      subtitle: Text('Cost: ${NumberFormat.currency(symbol: '\$').format(product.standardPrice)}'),
                      onTap: () {
                        setState(() {
                          selectedProductId = product.id;
                          selectedProductName = product.name;
                          _unitCostController.text = product.standardPrice.toString();
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

      final line = ReceiptLine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: selectedProductId!,
        productName: selectedProductName,
        quantityOrdered: double.parse(_quantityOrderedController.text),
        quantityReceived: double.parse(_quantityReceivedController.text),
        unitCost: double.parse(_unitCostController.text),
        lotNumber: _lotNumberController.text,
      );

      widget.onSave(line);
      Navigator.pop(context);
    }
  }
}