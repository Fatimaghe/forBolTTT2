import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/odoo_service.dart';
import 'package:provider/provider.dart';
import '../../providers/invoice_provider.dart';
import 'package:intl/intl.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Invoice? invoice;

  const AddInvoiceScreen({super.key, this.invoice});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _referenceController = TextEditingController();

  String? selectedCustomerId;
  String selectedCustomerName = '';
  List<Map<String, dynamic>> customerOptions = [];
  bool customerLoading = false;
  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 30));
  String selectedStatus = 'draft';
  String selectedPaymentTerms = 'Net 30';

  List<InvoiceLine> invoiceLines = [];

  final List<String> statusOptions = ['draft', 'posted', 'paid', 'cancelled'];
  final List<String> paymentTermsOptions = ['Net 15', 'Net 30', 'Net 60', 'Due on Receipt'];

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _loadInvoiceData();
    } else {
      _generateInvoiceNumber();
    }
    _fetchCustomerOptions();
  }

  Future<void> _fetchCustomerOptions() async {
    setState(() => customerLoading = true);
    try {
      final odoo = OdooService();
      final customers = await odoo.fetchCustomers();
      customerOptions = odoo.customerDropdownItems(customers);
    } catch (e) {
      customerOptions = [];
    }
    setState(() => customerLoading = false);
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _numberController.text = invoice.number;
    _referenceController.text = invoice.reference;
    selectedCustomerId = invoice.customerId;
    selectedCustomerName = invoice.customerName;
    invoiceDate = invoice.invoiceDate;
    dueDate = invoice.dueDate;
    selectedStatus = invoice.status;
    selectedPaymentTerms = invoice.paymentTerms;
    invoiceLines = List.from(invoice.lines);
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    _numberController.text = 'INV/${DateFormat('yyyy/MM').format(now)}/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'Add Invoice' : 'Edit Invoice'),
        actions: [
          Consumer<InvoiceProvider>(
            builder: (context, provider, _) => TextButton(
              onPressed: provider.loading ? null : _saveInvoice,
              child: provider.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('SAVE'),
            ),
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, _) => Form(
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
                            labelText: 'Invoice Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter invoice number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomerSelector(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(),
                          ),
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
                                'Invoice Date',
                                invoiceDate,
                                (date) => setState(() => invoiceDate = date),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                'Due Date',
                                dueDate,
                                (date) => setState(() => dueDate = date),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: statusOptions.contains(selectedStatus) ? selectedStatus : null,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: statusOptions
                                    .where((status) => status.isNotEmpty)
                                    .toSet()
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStatus = value ?? '';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: paymentTermsOptions.contains(selectedPaymentTerms) ? selectedPaymentTerms : null,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Terms',
                                  border: OutlineInputBorder(),
                                ),
                                items: paymentTermsOptions
                                    .where((terms) => terms.isNotEmpty)
                                    .toSet()
                                    .map((terms) => DropdownMenuItem(
                                          value: terms,
                                          child: Text(terms),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentTerms = value ?? '';
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

                // Invoice Lines
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
                              'Invoice Lines',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addInvoiceLine,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Line'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (invoiceLines.isEmpty)
                          const Center(
                            child: Text('No invoice lines added yet'),
                          )
                        else
                          ...invoiceLines.asMap().entries.map((entry) {
                            final index = entry.key;
                            final line = entry.value;
                            return _buildInvoiceLineCard(line, index);
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
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return customerLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        : DropdownButtonFormField<String>(
            value: selectedCustomerId,
            decoration: const InputDecoration(
              labelText: 'Customer',
              border: OutlineInputBorder(),
            ),
            items: customerOptions
                .map((c) => DropdownMenuItem<String>(
                      value: c['id'].toString(),
                      child: Text(c['name'] ?? ''),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCustomerId = value;
                selectedCustomerName = customerOptions.firstWhere(
                        (c) => c['id'].toString() == value,
                        orElse: () => {'name': ''})['name'] ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a customer';
              }
              return null;
            },
          );
  }

  void _selectCustomer() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchController = TextEditingController();
        List<Map<String, dynamic>> customers = [];
        bool loading = true;
        String? error;

        final odoo = OdooService();
        void fetch({String? search}) async {
          try {
            customers = await odoo.fetchCustomers(search: search);
            error = null;
          } catch (e) {
            error = e.toString();
          }
          loading = false;
          (context as Element).markNeedsBuild();
        }

        fetch();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Customer'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              loading = true;
                            });
                            fetch(search: searchController.text);
                          },
                        ),
                      ),
                      onSubmitted: (val) {
                        setState(() {
                          loading = true;
                        });
                        fetch(search: val);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else if (error != null)
                      Text(error!, style: TextStyle(color: Colors.red))
                    else if (customers.isEmpty)
                      const Text('No customers found')
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: customers.length,
                          itemBuilder: (context, idx) {
                            final c = customers[idx];
                            return ListTile(
                              title: Text(c['name'] ?? ''),
                              subtitle: Text((c['email'] ?? '') + (c['phone'] != null ? ' | ${c['phone']}' : '')),
                              onTap: () {
                                setState(() {
                                  selectedCustomerId = c['id'].toString();
                                  selectedCustomerName = c['name'] ?? '';
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
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

  Widget _buildInvoiceLineCard(InvoiceLine line, int index) {
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
                  onPressed: () => _removeInvoiceLine(index),
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
    final subtotal = invoiceLines.fold(0.0, (sum, line) => sum + line.subtotal);
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

  void _addInvoiceLine() {
    showDialog(
      context: context,
      builder: (context) => _InvoiceLineDialog(
        onSave: (line) {
          setState(() {
            invoiceLines.add(line);
          });
        },
      ),
    );
  }

  void _removeInvoiceLine(int index) {
    setState(() {
      invoiceLines.removeAt(index);
    });
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')),
        );
        return;
      }

      final subtotal = invoiceLines.fold(0.0, (sum, line) => sum + line.subtotal);
      final taxAmount = subtotal * 0.1;
      final totalAmount = subtotal + taxAmount;

      final invoice = Invoice(
        id: widget.invoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text,
        customerId: selectedCustomerId!,
        customerName: selectedCustomerName,
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        status: selectedStatus,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentTerms: selectedPaymentTerms,
        reference: _referenceController.text,
        lines: invoiceLines,
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      bool success;
      if (widget.invoice == null) {
        success = await provider.addInvoice(invoice);
      } else {
        success = await provider.updateInvoice(invoice);
      }
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to save invoice')),
        );
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}

class _InvoiceLineDialog extends StatefulWidget {
  final Function(InvoiceLine) onSave;

  const _InvoiceLineDialog({required this.onSave});

  @override
  State<_InvoiceLineDialog> createState() => _InvoiceLineDialogState();
}

class _InvoiceLineDialogState extends State<_InvoiceLineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  String? selectedProductId;
  String selectedProductName = '';
  List<Map<String, dynamic>> productOptions = [];
  bool productLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchProductOptions();
  }

  Future<void> _fetchProductOptions() async {
    setState(() => productLoading = true);
    try {
      final odoo = OdooService();
      final products = await odoo.fetchProducts();
      productOptions = odoo.productDropdownItems(products);
    } catch (e) {
      productOptions = [];
    }
    setState(() => productLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Invoice Line'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Discount (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
    return productLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        : DropdownButtonFormField<String>(
            value: selectedProductId,
            decoration: const InputDecoration(
              labelText: 'Product',
              border: OutlineInputBorder(),
            ),
            items: productOptions
                .map((p) => DropdownMenuItem<String>(
                      value: p['id'].toString(),
                      child: Text(p['name'] ?? ''),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedProductId = value;
                selectedProductName = productOptions.firstWhere(
                        (p) => p['id'].toString() == value,
                        orElse: () => {'name': ''})['name'] ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a product';
              }
              return null;
            },
          );
  }

  // _selectProduct removed (no longer needed)

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
      final discount = double.parse(_discountController.text);
      final subtotal = (quantity * unitPrice) * (1 - discount / 100);

      final line = InvoiceLine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: selectedProductId!,
        productName: selectedProductName,
        description: _descriptionController.text,
        quantity: quantity,
        unitPrice: unitPrice,
        discount: discount,
        taxRate: 10.0,
        subtotal: subtotal,
      );

      widget.onSave(line);
      Navigator.pop(context);
    }
  }
}