import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/dropdown_service.dart';
import '../../services/order_service.dart';

class OrderEditScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderEditScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  bool _loading = true;
  Map<String, List<Map<String, dynamic>>> dropdowns = {};

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.order);
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    final service = DropdownService();
    final partners = await service.getPartners();
    final paymentTerms = await service.getPaymentTerms();
    final templates = await service.getQuotationTemplates();
    final users = await service.getUsers();
    final teams = await service.getSalesTeams();
    final companies = await service.getCompanies();
    final products = await service.getProducts();
    final uoms = await service.getUoMs();
    final taxes = await service.getTaxes();
    setState(() {
      dropdowns = {
        'partners': partners,
        'paymentTerms': paymentTerms,
        'templates': templates,
        'users': users,
        'teams': teams,
        'companies': companies,
        'products': products,
        'uoms': uoms,
        'taxes': taxes,
      };
      _loading = false;
    });
  }

  bool _saving = false;

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);
    final localizations = AppLocalizations.of(context);
    try {
      // Prepare order values
      final orderId = widget.order['id'];
      final orderVals = Map<String, dynamic>.from(_formData);
      // Remove order_lines from main order update
      final lines = List<Map<String, dynamic>>.from(orderVals.remove('order_lines') ?? []);

      // Update order
      final orderService = OrderService();
      final ok = await orderService.updateOrder(orderId, orderVals);

      // Update or create order lines
      for (final line in lines) {
        if (line['id'] != null) {
          await orderService.updateOrderLine(line['id'], line);
        } else {
          await orderService.createOrderLine(orderId, line);
        }
      }

      // Optionally: delete removed lines (not implemented here)

      if (ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.savedSuccessfully)),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.saveFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.saveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final products = dropdowns['products'] ?? [];
    final uoms = dropdowns['uoms'] ?? [];
    final taxes = dropdowns['taxes'] ?? [];
    final partners = dropdowns['partners'] ?? [];
    final paymentTerms = dropdowns['paymentTerms'] ?? [];
    final templates = dropdowns['templates'] ?? [];
    final users = dropdowns['users'] ?? [];
    final companies = dropdowns['companies'] ?? [];
    List<Map<String, dynamic>> orderLines = List<Map<String, dynamic>>.from(_formData['order_lines'] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.edit)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Main Order Fields ---
                        DropdownButtonFormField<dynamic>(
                          value: _formData['partner_id'] is List && _formData['partner_id'].isNotEmpty ? _formData['partner_id'][0] : null,
                          items: partners.map((p) => DropdownMenuItem(
                            value: p['id'],
                            child: Text(p['name'] ?? ''),
                          )).toList(),
                          onChanged: (v) => setState(() => _formData['partner_id'] = [v]),
                          decoration: InputDecoration(labelText: localizations.customer),
                          isExpanded: true,
                          validator: (v) => v == null ? localizations.required : null,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<dynamic>(
                          value: _formData['payment_term_id'] is List && _formData['payment_term_id'].isNotEmpty ? _formData['payment_term_id'][0] : null,
                          items: paymentTerms.map((p) => DropdownMenuItem(
                            value: p['id'],
                            child: Text(p['name'] ?? ''),
                          )).toList(),
                          onChanged: (v) => setState(() => _formData['payment_term_id'] = v != null ? [v] : []),
                          decoration: InputDecoration(labelText: localizations.paymentTerms),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<dynamic>(
                          value: _formData['sale_order_template_id'] is List && _formData['sale_order_template_id'].isNotEmpty ? _formData['sale_order_template_id'][0] : null,
                          items: templates.map((t) => DropdownMenuItem(
                            value: t['id'],
                            child: Text(t['name'] ?? ''),
                          )).toList(),
                          onChanged: (v) => setState(() => _formData['sale_order_template_id'] = v != null ? [v] : []),
                          decoration: InputDecoration(labelText: localizations.quotationTemplate),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _formData['date_order'] != null ? DateTime.tryParse(_formData['date_order']) ?? DateTime.now() : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _formData['date_order'] = picked.toIso8601String();
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _formData['date_order'] != null ? (_formData['date_order'] as String).split('T').first : '',
                              ),
                              decoration: InputDecoration(labelText: localizations.orderDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<dynamic>(
                          value: _formData['user_id'] is List && _formData['user_id'].isNotEmpty ? _formData['user_id'][0] : null,
                          items: users.map((u) => DropdownMenuItem(
                            value: u['id'],
                            child: Text(u['name'] ?? ''),
                          )).toList(),
                          onChanged: (v) => setState(() => _formData['user_id'] = v != null ? [v] : []),
                          decoration: InputDecoration(labelText: localizations.salesperson),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<dynamic>(
                          value: _formData['company_id'] is List && _formData['company_id'].isNotEmpty ? _formData['company_id'][0] : null,
                          items: companies.map((c) => DropdownMenuItem(
                            value: c['id'],
                            child: Text(c['name'] ?? ''),
                          )).toList(),
                          onChanged: (v) => setState(() => _formData['company_id'] = v != null ? [v] : []),
                          decoration: InputDecoration(labelText: localizations.company),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 16),
                        // --- Order Lines Editing UI (same as before) ---
                        Text(localizations.orderLines, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderLines.length,
                          itemBuilder: (context, idx) {
                            final line = orderLines[idx];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<dynamic>(
                                            value: line['product_id'] is List && line['product_id'].isNotEmpty ? line['product_id'][0] : null,
                                            items: products.map((p) => DropdownMenuItem(
                                              value: p['id'],
                                              child: Text(p['name'] ?? ''),
                                            )).toList(),
                                            onChanged: (v) {
                                              setState(() {
                                                line['product_id'] = [v];
                                              });
                                            },
                                            decoration: InputDecoration(labelText: localizations.product),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: localizations.delete,
                                          onPressed: () {
                                            setState(() {
                                              orderLines.removeAt(idx);
                                              _formData['order_lines'] = orderLines;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: line['name'] ?? '',
                                      decoration: InputDecoration(labelText: localizations.description),
                                      onChanged: (v) => line['name'] = v,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: line['product_uom_qty']?.toString() ?? '0',
                                            decoration: InputDecoration(labelText: localizations.quantity),
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => line['product_uom_qty'] = double.tryParse(v) ?? 0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DropdownButtonFormField<dynamic>(
                                            value: line['product_uom'] is List && line['product_uom'].isNotEmpty ? line['product_uom'][0] : null,
                                            items: uoms.map((u) => DropdownMenuItem(
                                              value: u['id'],
                                              child: Text(u['name'] ?? ''),
                                            )).toList(),
                                            onChanged: (v) {
                                              setState(() {
                                                line['product_uom'] = [v];
                                              });
                                            },
                                            decoration: InputDecoration(labelText: localizations.unitOfMeasure),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: line['price_unit']?.toString() ?? '0',
                                      decoration: InputDecoration(labelText: localizations.price),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => line['price_unit'] = double.tryParse(v) ?? 0,
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      value: (line['tax_id'] is List && line['tax_id'].isNotEmpty)
                                          ? line['tax_id'][0]
                                          : null,
                                      items: taxes.map((t) => DropdownMenuItem<int>(
                                        value: t['id'],
                                        child: Text(t['name'] ?? ''),
                                      )).toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          line['tax_id'] = v != null ? [v] : [];
                                        });
                                      },
                                      isExpanded: true,
                                      decoration: InputDecoration(labelText: localizations.taxes),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(localizations.add),
                            onPressed: () {
                              setState(() {
                                orderLines.add({
                                  'product_id': [],
                                  'name': '',
                                  'product_uom_qty': 1,
                                  'product_uom': [],
                                  'price_unit': 0,
                                  'tax_id': [],
                                });
                                _formData['order_lines'] = orderLines;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _saving ? null : _saveOrder,
                              child: _saving
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(localizations.save),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_saving)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
