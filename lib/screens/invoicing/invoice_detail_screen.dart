import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import 'add_invoice_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/invoice_provider.dart';
import 'package:intl/intl.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice invoice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.number),
        actions: [
          Consumer<InvoiceProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddInvoiceScreen(invoice: invoice),
                        ),
                      );
                      if (result == true) {
                        setState(() => _isLoading = true);
                        await provider.fetchInvoices();
                        final updated = provider.invoices.firstWhere(
                          (inv) => inv.id == invoice.id,
                          orElse: () => invoice,
                        );
                        setState(() {
                          invoice = updated;
                          _isLoading = false;
                        });
                      }
                    },
            ),
          ),
          Consumer<InvoiceProvider>(
            builder: (context, provider, _) => IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Invoice'),
                          content: const Text('Are you sure you want to delete this invoice?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() => _isLoading = true);
                        final success = await provider.deleteInvoice(invoice.id);
                        setState(() => _isLoading = false);
                        if (success) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error ?? 'Failed to delete invoice')),
                          );
                        }
                      }
                    },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(invoice.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: _getStatusColor(invoice.status),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoice.number,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(invoice.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        invoice.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(invoice.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  'Total Amount',
                                  NumberFormat.currency(symbol: '\$').format(invoice.totalAmount),
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  context,
                                  'Due Date',
                                  DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                                  _isDueOverdue() ? Colors.red : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Customer & Invoice Info
                  _buildSection(context, 'Customer & Invoice Info', [
                    _buildInfoRow(Icons.person, 'Customer', invoice.customerName),
                    _buildInfoRow(Icons.location_on, 'Address', ''), // Placeholder for address
                    _buildInfoRow(Icons.calendar_today, 'Invoice Date', DateFormat('yyyy-MM-dd').format(invoice.invoiceDate)),
                    _buildInfoRow(Icons.calendar_today, 'Due Date', DateFormat('yyyy-MM-dd').format(invoice.dueDate)),
                    _buildInfoRow(Icons.payment, 'Payment Terms', invoice.paymentTerms),
                    _buildInfoRow(Icons.numbers, 'Reference', invoice.reference),
                  ]),

                  // Sales & Company Info
                  _buildSection(context, 'Sales & Company Info', [
                    _buildInfoRow(Icons.account_circle, 'Salesperson', ''), // Placeholder
                    _buildInfoRow(Icons.group, 'Sales Team', ''), // Placeholder
                    _buildInfoRow(Icons.business, 'Company', ''), // Placeholder
                    _buildInfoRow(Icons.attach_money, 'Currency', ''), // Placeholder
                    _buildInfoRow(Icons.account_balance, 'Recipient Bank', ''), // Placeholder
                    _buildInfoRow(Icons.calendar_today, 'Delivery Date', ''), // Placeholder
                    _buildInfoRow(Icons.assignment, 'Customer Reference', ''), // Placeholder
                  ]),

                  // Invoice Lines
                  _buildSection(context, 'Invoice Lines', [
                    if (invoice.lines.isEmpty)
                      const Text('No invoice lines'),
                    if (invoice.lines.isNotEmpty)
                      ...invoice.lines.map(_buildInvoiceLine).toList(),
                    const Divider(),
                    _buildTotalRow('Subtotal', invoice.subtotal),
                    _buildTotalRow('Tax', invoice.taxAmount),
                    _buildTotalRow('Total', invoice.totalAmount, isTotal: true),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceLine(InvoiceLine line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (line.description.isNotEmpty)
                  Text(
                    line.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${line.quantity.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.currency(symbol: '\$').format(line.unitPrice),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.currency(symbol: '\$').format(line.subtotal),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
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

  bool _isDueOverdue() {
    return invoice.status == 'posted' && invoice.dueDate.isBefore(DateTime.now());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'posted':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}