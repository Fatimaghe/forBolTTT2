import 'package:flutter/material.dart';
import '../../models/stock_transfer.dart';
import '../../data/dummy_data.dart';
import 'package:intl/intl.dart';

class AddTransferScreen extends StatefulWidget {
  final StockTransfer? transfer;

  const AddTransferScreen({super.key, this.transfer});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _responsiblePersonController = TextEditingController();

  String? selectedSourceLocationId;
  String selectedSourceLocationName = '';
  String? selectedDestinationLocationId;
  String selectedDestinationLocationName = '';
  DateTime scheduledDate = DateTime.now();
  String selectedStatus = 'draft';

  List<StockTransferLine> transferLines = [];

  final List<String> statusOptions = ['draft', 'waiting', 'ready', 'done', 'cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.transfer != null) {
      _loadTransferData();
    } else {
      _generateReference();
    }
  }

  void _loadTransferData() {
    final transfer = widget.transfer!;
    _referenceController.text = transfer.reference;
    _notesController.text = transfer.notes;
    _responsiblePersonController.text = transfer.responsiblePerson;
    selectedSourceLocationId = transfer.sourceLocationId;
    selectedSourceLocationName = transfer.sourceLocationName;
    selectedDestinationLocationId = transfer.destinationLocationId;
    selectedDestinationLocationName = transfer.destinationLocationName;
    scheduledDate = transfer.scheduledDate;
    selectedStatus = transfer.status;
    transferLines = List.from(transfer.lines);
  }

  void _generateReference() {
    final now = DateTime.now();
    _referenceController.text = 'WH/OUT/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transfer == null ? 'Add Transfer' : 'Edit Transfer'),
        actions: [
          TextButton(
            onPressed: _saveTransfer,
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
                        'Transfer Information',
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
                      TextFormField(
                        controller: _responsiblePersonController,
                        decoration: const InputDecoration(
                          labelText: 'Responsible Person',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter responsible person';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Scheduled Date',
                              scheduledDate,
                                  (date) => setState(() => scheduledDate = date),
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

              // Locations
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLocationSelector(
                        'Source Location',
                        selectedSourceLocationName,
                            () => _selectLocation(true),
                      ),
                      const SizedBox(height: 16),
                      _buildLocationSelector(
                        'Destination Location',
                        selectedDestinationLocationName,
                            () => _selectLocation(false),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transfer Lines
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
                            'Transfer Lines',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addTransferLine,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Line'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (transferLines.isEmpty)
                        const Center(
                          child: Text('No transfer lines added yet'),
                        )
                      else
                        ...transferLines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                          return _buildTransferLineCard(line, index);
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

  Widget _buildLocationSelector(String label, String selectedLocation, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
                    selectedLocation.isEmpty ? 'Select Location' : selectedLocation,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLocation.isEmpty ? Colors.grey : Colors.black,
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

  Widget _buildTransferLineCard(StockTransferLine line, int index) {
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
                  onPressed: () => _removeTransferLine(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Demand: ${line.demandQuantity.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: Text('Done: ${line.doneQuantity.toStringAsFixed(0)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation(bool isSource) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select ${isSource ? 'Source' : 'Destination'} Location',
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
                          if (isSource) {
                            selectedSourceLocationId = location.id;
                            selectedSourceLocationName = location.name;
                          } else {
                            selectedDestinationLocationId = location.id;
                            selectedDestinationLocationName = location.name;
                          }
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

  void _addTransferLine() {
    showDialog(
      context: context,
      builder: (context) => _TransferLineDialog(
        onSave: (line) {
          setState(() {
            transferLines.add(line);
          });
        },
      ),
    );
  }

  void _removeTransferLine(int index) {
    setState(() {
      transferLines.removeAt(index);
    });
  }

  void _saveTransfer() {
    if (_formKey.currentState!.validate()) {
      if (selectedSourceLocationId == null || selectedDestinationLocationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both source and destination locations')),
        );
        return;
      }

      final transfer = StockTransfer(
        id: widget.transfer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        reference: _referenceController.text,
        sourceLocationId: selectedSourceLocationId!,
        sourceLocationName: selectedSourceLocationName,
        destinationLocationId: selectedDestinationLocationId!,
        destinationLocationName: selectedDestinationLocationName,
        scheduledDate: scheduledDate,
        status: selectedStatus,
        responsiblePerson: _responsiblePersonController.text,
        lines: transferLines,
        notes: _notesController.text,
        createdAt: widget.transfer?.createdAt ?? DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, transfer);
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    _responsiblePersonController.dispose();
    super.dispose();
  }
}

class _TransferLineDialog extends StatefulWidget {
  final Function(StockTransferLine) onSave;

  const _TransferLineDialog({required this.onSave});

  @override
  State<_TransferLineDialog> createState() => _TransferLineDialogState();
}

class _TransferLineDialogState extends State<_TransferLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _demandQuantityController = TextEditingController(text: '1');
  final _doneQuantityController = TextEditingController(text: '0');

  String? selectedProductId;
  String selectedProductName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transfer Line'),
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
                      controller: _demandQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Demand Quantity',
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
                      controller: _doneQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Done Quantity',
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

      final demandQty = double.parse(_demandQuantityController.text);
      final doneQty = double.parse(_doneQuantityController.text);

      final line = StockTransferLine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: selectedProductId!,
        productName: selectedProductName,
        quantityDemand: demandQty,
        quantityDone: doneQty,
        unit: 'Units',
        demandQuantity: demandQty,
        doneQuantity: doneQty,
      );

      widget.onSave(line);
      Navigator.pop(context);
    }
  }
}