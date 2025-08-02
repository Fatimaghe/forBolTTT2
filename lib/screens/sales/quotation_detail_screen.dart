import 'package:flutter/material.dart';
import '../../models/quotation.dart';
import 'edit_quotation_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/quotation_service.dart';

class QuotationDetailScreen extends StatelessWidget {
  final Quotation quotation;

  const QuotationDetailScreen({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(quotation.number),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: localizations.edit,
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditQuotationScreen(quotation: quotation),
                ),
              );
              if (updated != null && updated is Quotation) {
                // Refresh the details screen with updated data
                Navigator.pop(context, updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: localizations.delete + ' ' + localizations.quotationsTitle,
            onPressed: () {
              _confirmDelete(context);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'convert':
                  _convertToOrder(context);
                  break;
                case 'send':
                  _sendQuotation(context);
                  break;
                case 'cancel':
                  _cancelQuotation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'convert',
                child: Text(localizations.quotationsTitle + ' → ' + localizations.orders),
              ),
              PopupMenuItem(
                value: 'send',
                child: Text(localizations.send + ' ' + localizations.quotationsTitle),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Text(localizations.cancel),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quotation Header
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
                            color: _getStatusColor(quotation.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.description,
                            color: _getStatusColor(quotation.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quotation.number,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.created + ': ' + DateFormat('MMM dd, yyyy').format(quotation.createdAt),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.quotationsCustomer(quotation.customerName),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.quotationsSalesperson(quotation.salesPerson),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.quotationsCompany(quotation.customerName),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(quotation.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            quotation.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(quotation.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            localizations.total,
                            NumberFormat.currency(symbol: '\$').format(quotation.totalAmount),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            localizations.quotationsOrderDate(DateFormat('MMM dd, yyyy').format(quotation.quotationDate)),
                            DateFormat('MMM dd, yyyy').format(quotation.quotationDate),
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

            // Quotation Details
            _buildSection(
              context,
              localizations.moreDetails,
              [
                _buildInfoRow(Icons.person, localizations.salesPerson, quotation.salesPerson),
                _buildInfoRow(Icons.business, localizations.company, quotation.customerName),
                _buildInfoRow(Icons.location_on, localizations.address, 'N/A'),
                _buildInfoRow(Icons.calendar_today, localizations.quotationsOrderDate(DateFormat('MMM dd, yyyy').format(quotation.quotationDate)), DateFormat('MMM dd, yyyy').format(quotation.quotationDate)),
                _buildInfoRow(Icons.calendar_today, localizations.created, DateFormat('MMM dd, yyyy').format(quotation.createdAt)),
                _buildInfoRow(Icons.note, localizations.notes, quotation.notes),
                _buildInfoRow(Icons.check_circle, localizations.activities ?? 'Activities', localizations.noDataFound),
              ],
            ),

            const SizedBox(height: 16),

            // Quotation Lines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.invoiceLines,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(localizations.productName)),
                          DataColumn(label: Text(localizations.description)),
                          DataColumn(label: Text(localizations.quantity)),
                          DataColumn(label: Text(localizations.delivered ?? 'Delivered')),
                          DataColumn(label: Text(localizations.invoiced ?? 'Invoiced')),
                          DataColumn(label: Text(localizations.price)),
                          DataColumn(label: Text(localizations.tax)),
                          DataColumn(label: Text(localizations.subtotal)),
                        ],
                        rows: quotation.lines.map((line) => DataRow(cells: [
                          DataCell(Text(line.productName)),
                          DataCell(Text(line.description)),
                          DataCell(Text(line.quantity.toString())),
                          DataCell(Text('0')), // Delivered (placeholder)
                          DataCell(Text('0')), // Invoiced (placeholder)
                          DataCell(Text(NumberFormat.currency(symbol: '\$').format(line.unitPrice))),
                          DataCell(Text('0')), // Taxes (placeholder)
                          DataCell(Text(NumberFormat.currency(symbol: '\$').format(line.subtotal))),
                        ])).toList(),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.subtotal,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(quotation.subtotal),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.tax,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(quotation.taxAmount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.total,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(quotation.totalAmount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (quotation.status == 'draft') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _sendQuotation(context),
                  icon: const Icon(Icons.send),
                  label: Text(localizations.send + ' ' + localizations.customer),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (quotation.status == 'sent') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _convertToOrder(context),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(localizations.quotationsTitle + ' → ' + localizations.orders),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Print or share quotation
                },
                icon: const Icon(Icons.share),
                label: Text(localizations.share ?? 'Share Quotation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(
            fontSize: 12,
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

  Widget _buildOrderLineItem(QuotationLine line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(line.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(child: Text('${line.quantity}', textAlign: TextAlign.center)),
          Expanded(child: Text('0', textAlign: TextAlign.center)), // Delivered (placeholder)
          Expanded(child: Text('0', textAlign: TextAlign.center)), // Invoiced (placeholder)
          Expanded(child: Text(NumberFormat.currency(symbol: '\$').format(line.unitPrice), textAlign: TextAlign.center)),
          Expanded(child: Text('0', textAlign: TextAlign.center)), // Taxes (placeholder)
          Expanded(child: Text(NumberFormat.currency(symbol: '\$').format(line.subtotal), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _sendQuotation(BuildContext context) {
    // TODO: Implement send quotation logic
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.quotationsSentSuccess),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _convertToOrder(BuildContext context) {
    // TODO: Implement convert to order logic
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.quotationConvertedSuccess),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelQuotation(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.cancelQuotationTitle),
        content: Text(localizations.cancelQuotationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.no),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              String? errorMsg;
              bool cancelled = false;
              try {
                await QuotationService().cancelQuotation(quotation.id);
                cancelled = true;
              } catch (e) {
                errorMsg = e.toString().replaceFirst('Exception: ', '');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cancelled
                        ? localizations.quotationCancelledSuccess
                        : errorMsg ?? localizations.quotationCancelledFailed),
                    backgroundColor: cancelled ? Colors.orange : Colors.red,
                  ),
                );
                if (cancelled) {
                  // Update the UI to reflect the cancellation
                  Navigator.pop(context, {
                    'updatedQuotation': quotation.copyWith(status: 'cancelled'),
                  });
                }
              }
            },
            child: Text(localizations.yes),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteQuotationTitle),
        content: Text(localizations.deleteQuotationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.no),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              String? errorMsg;
              bool deleted = false;
              try {
                await QuotationService().deleteQuotation(quotation.id);
                deleted = true;
              } catch (e) {
                errorMsg = e.toString().replaceFirst('Exception: ', '');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(deleted
                        ? localizations.quotationsDeletedSuccess
                        : errorMsg ?? localizations.quotationDeletedFailed),
                    backgroundColor: deleted ? Colors.green : Colors.red,
                  ),
                );
                if (deleted) {
                  Navigator.pop(context, {
                    'deletedId': quotation.id,
                  });
                }
              }
            },
            child: Text(localizations.yes),
          ),
        ],
      ),
    );
  }

}