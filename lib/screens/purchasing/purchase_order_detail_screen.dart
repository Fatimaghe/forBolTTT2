import 'package:flutter/material.dart';
import '../../models/purchase_order.dart';
import 'add_purchase_order_screen.dart';
import 'package:intl/intl.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final PurchaseOrder purchaseOrder;

  const PurchaseOrderDetailScreen({super.key, required this.purchaseOrder});

  @override
  State<PurchaseOrderDetailScreen> createState() => _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  late PurchaseOrder purchaseOrder;

  @override
  void initState() {
    super.initState();
    purchaseOrder = widget.purchaseOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(purchaseOrder.number),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPurchaseOrderScreen(purchaseOrder: purchaseOrder),
                ),
              );
              if (result != null) {
                setState(() {
                  purchaseOrder = result;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
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
                            color: _getStatusColor(purchaseOrder.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: _getStatusColor(purchaseOrder.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                purchaseOrder.number,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(purchaseOrder.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  purchaseOrder.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(purchaseOrder.status),
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
                            NumberFormat.currency(symbol: '\$').format(purchaseOrder.totalAmount),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Expected Date',
                            DateFormat('MMM dd').format(purchaseOrder.expectedDate),
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Supplier Information
            _buildSection(
              context,
              'Supplier Information',
              [
                _buildInfoRow(Icons.business, 'Supplier', purchaseOrder.supplierName),
                _buildInfoRow(Icons.payment, 'Payment Terms', purchaseOrder.paymentTerms),
                if (purchaseOrder.reference.isNotEmpty)
                  _buildInfoRow(Icons.tag, 'Reference', purchaseOrder.reference),
              ],
            ),

            const SizedBox(height: 16),

            // Order Details
            _buildSection(
              context,
              'Order Details',
              [
                _buildInfoRow(
                  Icons.calendar_today,
                  'Order Date',
                  DateFormat('MMM dd, yyyy').format(purchaseOrder.orderDate),
                ),
                _buildInfoRow(
                  Icons.schedule,
                  'Expected Date',
                  DateFormat('MMM dd, yyyy').format(purchaseOrder.expectedDate),
                ),
                _buildInfoRow(
                  Icons.access_time,
                  'Created',
                  DateFormat('MMM dd, yyyy').format(purchaseOrder.createdAt),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order Lines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Lines',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...purchaseOrder.lines.map((line) => _buildOrderLine(line)),
                    const Divider(),
                    _buildTotalRow('Subtotal', purchaseOrder.subtotal),
                    _buildTotalRow('Tax', purchaseOrder.taxAmount),
                    const Divider(thickness: 2),
                    _buildTotalRow('Total', purchaseOrder.totalAmount, isTotal: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (purchaseOrder.status == 'draft') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Send purchase order
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Order'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Cancel order
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ] else if (purchaseOrder.status == 'sent') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Confirm order
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm Order'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Create receipt
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('Create Receipt'),
                    ),
                  ),
                ],
              ),
            ],
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

  Widget _buildOrderLine(PurchaseOrderLine line) {
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}