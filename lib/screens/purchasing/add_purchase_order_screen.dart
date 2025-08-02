import 'package:flutter/material.dart';
import '../../models/purchase_order.dart';
import '../../data/dummy_data.dart';
import 'package:intl/intl.dart';

class AddPurchaseOrderScreen extends StatefulWidget {
  final PurchaseOrder? purchaseOrder;

  const AddPurchaseOrderScreen({super.key, this.purchaseOrder});

  @override
  State<AddPurchaseOrderScreen> createState() => _AddPurchaseOrderScreenState();
}

class _AddPurchaseOrderScreenState extends State<AddPurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _referenceController = TextEditingController();
  final _buyerController = TextEditingController();

  String? selectedSupplierId;
  String selectedSupplierName = '';
  DateTime orderDate = DateTime.now();
  DateTime expectedDate = DateTime.now().add(const Duration(days: 7));
  String selectedStatus = 'draft';
  String selectedPaymentTerms = 'Net 30';

  List<PurchaseOrderLine> orderLines = [];

  final List<String> statusOptions = ['draft', 'sent', 'confirmed', 'done', 'cancelled'];
  final List<String> paymentTermsOptions = ['Net 15', 'Net 30', 'Net 60', 'Due on Receipt'];

  @override
  void initState() {
    super.initState();
    if (widget.purchaseOrder != null) {
      _loadOrderData();
    } else {
      _generateOrderNumber();
    }
  }

  void _loadOrderData() {
    final order = widget.purchaseOrder!;
    _numberController.text = order.number;
    _referenceController.text = order.reference;
    _buyerController.text = order.buyer;
    selectedSupplierId = order.supplierId;
    selectedSupplierName = order.supplierName;
    orderDate = order.orderDate;
    expectedDate = order.expectedDate;
    selectedStatus = order.status;
    selectedPaymentTerms = order.paymentTerms;
    orderLines = List.from(order.lines);
  }

  void _generateOrderNumber() {
    final now = DateTime.now();
    _numberController.text = 'PO/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchaseOrder == null ? 'Add Purchase Order' : 'Edit Purchase Order'),
        actions: [
          TextButton(
            onPressed: _saveOrder,
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
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Order Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter order number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSupplierSelector(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: const InputDecoration(
                                labelText: 'Reference',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _buyerController,
                              decoration: const InputDecoration(
                                labelText: 'Buyer',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter buyer';
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

              const SizedBox(height: 16),

              // Dates and Terms
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dates & Terms',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Order Date',
                              orderDate,
                                  (date) => setState(() => orderDate = date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              'Expected Date',
                              expectedDate,
                                  (date) => setState(() => expectedDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedPaymentTerms,
                              decoration: const InputDecoration(
                                labelText: 'Payment Terms',
                                border: OutlineInputBorder(),
                              ),
                              items: paymentTermsOptions.map((terms) {
                                return DropdownMenuItem(
                                  value: terms,
                                  child: Text(terms),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentTerms = value!;
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

              // Order Lines
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
                            'Order Lines',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addOrderLine,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Line'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (orderLines.isEmpty)
                        const Center(
                          child: Text('No order lines added yet'),
                        )
                      else
                        ...orderLines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                          return _buildOrderLineCard(line, index);
                        }),
                      const SizedBox(height: 16),
                      _buildTotals(),
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

  Widget _buildOrderLineCard(PurchaseOrderLine line, int index) {
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
                  onPressed: () => _removeOrderLine(index),
                ),
              ],
            ),
            if (line.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                line.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Qty: ${line.quantity.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: Text('Price: ${NumberFormat.currency(symbol: '\$').format(line.unitPrice)}'),
                ),
                Expanded(
                  child: Text(
                    'Total: ${NumberFormat.currency(symbol: '\$').format(line.subtotal)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotals() {
    final subtotal = orderLines.fold(0.0, (sum, line) => sum + line.subtotal);
    final taxAmount = subtotal * 0.1; // 10% tax
    final total = subtotal + taxAmount;

    return Column(
      children: [
        const Divider(),
        _buildTotalRow('Subtotal', subtotal),
        _buildTotalRow('Tax (10%)', taxAmount),
        const Divider(thickness: 2),
        _buildTotalRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
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

  void _addOrderLine() {
    showDialog(
      context: context,
      builder: (context) => _OrderLineDialog(
        onSave: (line) {
          setState(() {
            orderLines.add(line);
          });
        },
      ),
    );
  }

  void _removeOrderLine(int index) {
    setState(() {
      orderLines.removeAt(index);
    });
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      if (selectedSupplierId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a supplier')),
        );
        return;
      }

      final subtotal = orderLines.fold(0.0, (sum, line) => sum + line.subtotal);
      final taxAmount = subtotal * 0.1;
      final totalAmount = subtotal + taxAmount;

      final order = PurchaseOrder(
        id: widget.purchaseOrder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text,
        supplierId: selectedSupplierId!,
        supplierName: selectedSupplierName,
        buyer: _buyerController.text,
        orderDate: orderDate,
        expectedDate: expectedDate,
        status: selectedStatus,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentTerms: selectedPaymentTerms,
        reference: _referenceController.text,
        lines: orderLines,
        createdAt: widget.purchaseOrder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save to Odoo API
      Navigator.pop(context, order);
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _referenceController.dispose();
    _buyerController.dispose();
    super.dispose();
  }
}

class _OrderLineDialog extends StatefulWidget {
  final Function(PurchaseOrderLine) onSave;

  const _OrderLineDialog({required this.onSave});

  @override
  State<_OrderLineDialog> createState() => _OrderLineDialogState();
}

class _OrderLineDialogState extends State<_OrderLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();

  String? selectedProductId;
  String selectedProductName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Order Line'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProductSelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
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
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
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
                      subtitle: Text(NumberFormat.currency(symbol: '\$').format(product.standardPrice)),
                      onTap: () {
                        setState(() {
                          selectedProductId = product.id;
                          selectedProductName = product.name;
                          _unitPriceController.text = product.standardPrice.toString();
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

      final quantity = double.parse(_quantityController.text);
      final unitPrice = double.parse(_unitPriceController.text);
      final subtotal = quantity * unitPrice;

      final line = PurchaseOrderLine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: selectedProductId!,
        productName: selectedProductName,
        description: _descriptionController.text,
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
      );

      widget.onSave(line);
      Navigator.pop(context);
    }
  }
}