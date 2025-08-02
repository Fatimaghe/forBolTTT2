import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import 'package:provider/provider.dart';
import '../../providers/invoice_provider.dart';
import 'invoice_detail_screen.dart';
import 'add_invoice_screen.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    });
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    return invoices.where((invoice) {
      final matchesSearch = invoice.number.toLowerCase().contains(searchQuery.toLowerCase()) ||
          invoice.customerName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == 'All' || invoice.status == selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final filteredInvoices = _filterInvoices(provider.invoices);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Invoices'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddInvoiceScreen()),
                  );
                  if (result == true) {
                    provider.fetchInvoices();
                  }
                },
              ),
            ],
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and Filter
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search invoices...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['All', 'Draft', 'Posted', 'Paid', 'Cancelled'].map((status) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(status),
                                      selected: selectedStatus == status,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedStatus = status;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Summary Cards
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Invoices',
                                filteredInvoices.length.toString(),
                                Icons.receipt_long,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Amount',
                                NumberFormat.currency(symbol: '\$').format(
                                  filteredInvoices.fold(0.0, (sum, invoice) => sum + invoice.totalAmount),
                                ),
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Overdue',
                                filteredInvoices.where((i) =>
                                  i.status == 'posted' && i.dueDate.isBefore(DateTime.now())
                                ).length.toString(),
                                Icons.warning,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Invoices List
                      filteredInvoices.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No invoices found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredInvoices.length,
                              itemBuilder: (context, index) {
                                final invoice = filteredInvoices[index];
                                return _buildInvoiceCard(invoice);
                              },
                            ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isOverdue = invoice.status == 'posted' && invoice.dueDate.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(invoice.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long,
            color: _getStatusColor(invoice.status),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                invoice.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(invoice.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invoice.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(invoice.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(invoice.customerName),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(invoice.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailScreen(invoice: invoice),
            ),
          );
        },
      ),
    );
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