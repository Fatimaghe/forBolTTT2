import 'package:flutter/material.dart';
import '../../models/quotation.dart';
import '../../models/customer.dart';
import '../../services/crm_service.dart';
import 'package:intl/intl.dart';
import '../../services/quotation_service.dart';
import '../../l10n/app_localizations.dart';

class EditQuotationScreen extends StatefulWidget {
  final Quotation quotation;
  const EditQuotationScreen({super.key, required this.quotation});

  @override
  State<EditQuotationScreen> createState() => _EditQuotationScreenState();
}

class _EditQuotationScreenState extends State<EditQuotationScreen> {
  late TextEditingController numberController;
  late TextEditingController salesPersonController;
  late TextEditingController notesController;
  late TextEditingController totalController;
  late TextEditingController paymentTermsController;
  late TextEditingController referenceController;
  DateTime? quotationDate;
  DateTime? validUntil;
  String status = '';
  Customer? selectedCustomer;
  List<Customer> customers = [];
  bool isLoadingCustomers = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController(text: widget.quotation.number);
    salesPersonController = TextEditingController(text: widget.quotation.salesPerson);
    notesController = TextEditingController(text: widget.quotation.notes);
    totalController = TextEditingController(text: widget.quotation.totalAmount.toString());
    paymentTermsController = TextEditingController(text: widget.quotation.paymentTerms);
    referenceController = TextEditingController(text: widget.quotation.reference);
    quotationDate = widget.quotation.quotationDate;
    validUntil = widget.quotation.validUntil;
    status = widget.quotation.status;
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final fetched = await CrmService().getCustomers(customerType: 'all');
      Customer current = fetched.firstWhere(
        (c) => c.id == widget.quotation.customerId,
        orElse: () => Customer(
          id: widget.quotation.customerId,
          name: widget.quotation.customerName,
          email: '',
          phone: '',
          address: '',
          city: '',
          state: '',
          country: '',
          zipCode: '',
          website: '',
          industry: '',
          customerType: '',
          isActive: true,
          status: '',
          createdAt: DateTime.now(),
        ),
      );
      // Remove any duplicates of the selected customer
      fetched.removeWhere((c) => c.id == current.id);
      // Add the selected customer to the top if it has a valid id
      if (current.id.isNotEmpty) {
        fetched.insert(0, current);
      }
      setState(() {
        customers = fetched;
        selectedCustomer = current;
        isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCustomers = false;
        errorMessage = 'Failed to load customers';
      });
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    salesPersonController.dispose();
    notesController.dispose();
    totalController.dispose();
    paymentTermsController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      isSaving = true;
      errorMessage = null;
    });
    try {
      final updatedQuotation = Quotation(
        id: widget.quotation.id,
        number: numberController.text,
        customerId: selectedCustomer?.id ?? widget.quotation.customerId,
        customerName: selectedCustomer?.name ?? widget.quotation.customerName,
        quotationDate: quotationDate ?? widget.quotation.quotationDate,
        validUntil: validUntil ?? widget.quotation.validUntil,
        status: status,
        salesPerson: salesPersonController.text,
        subtotal: widget.quotation.subtotal,
        taxAmount: widget.quotation.taxAmount,
        totalAmount: double.tryParse(totalController.text) ?? widget.quotation.totalAmount,
        paymentTerms: paymentTermsController.text,
        reference: referenceController.text,
        lines: widget.quotation.lines,
        notes: notesController.text,
        createdAt: widget.quotation.createdAt,
        updatedAt: DateTime.now(),
      );
      await QuotationService().updateQuotation(updatedQuotation);
      if (mounted) {
        Navigator.pop(context, updatedQuotation);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.edit + ' ' + localizations.quotationsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoadingCustomers
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: numberController,
                          decoration: InputDecoration(labelText: localizations.number),
                        ),
                        DropdownButtonFormField<Customer>(
                          value: customers.isNotEmpty
                              ? customers.firstWhere(
                                  (c) => c.id == selectedCustomer?.id,
                                  orElse: () => customers.first,
                                )
                              : null,
                          items: customers
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name),
                                  ))
                              .toList(),
                          onChanged: (c) => setState(() => selectedCustomer = c),
                          decoration: InputDecoration(labelText: localizations.customer),
                        ),
                        TextField(
                          controller: salesPersonController,
                          decoration: InputDecoration(labelText: localizations.salesPerson),
                        ),
                        TextField(
                          controller: paymentTermsController,
                          decoration: InputDecoration(labelText: localizations.paymentTerms),
                        ),
                        TextField(
                          controller: referenceController,
                          decoration: InputDecoration(labelText: localizations.reference),
                        ),
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(labelText: localizations.notes),
                        ),
                        TextField(
                          controller: totalController,
                          decoration: InputDecoration(labelText: localizations.total),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(localizations.quotationsOrderDate('')),
                                subtitle: Text(quotationDate != null ? DateFormat('yyyy-MM-dd').format(quotationDate!) : ''),
                                trailing: Icon(Icons.calendar_today),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: quotationDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => quotationDate = picked);
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(localizations.validUntil),
                                subtitle: Text(validUntil != null ? DateFormat('yyyy-MM-dd').format(validUntil!) : ''),
                                trailing: Icon(Icons.calendar_today),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: validUntil ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => validUntil = picked);
                                },
                              ),
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          value: ['draft', 'sent', 'confirmed', 'cancelled'].contains(status)
                              ? status
                              : 'draft',
                          items: ['draft', 'sent', 'confirmed', 'cancelled']
                              .toSet()
                              .map((s) => DropdownMenuItem(value: s, child: Text(localizations.statusLabel(s))))
                              .toList(),
                          onChanged: (s) => setState(() => status = s ?? status),
                          decoration: InputDecoration(labelText: localizations.status),
                        ),
                        const SizedBox(height: 24),
                        if (errorMessage != null)
                          Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveChanges,
                            child: isSaving ? const CircularProgressIndicator() : Text(localizations.saveChanges),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
