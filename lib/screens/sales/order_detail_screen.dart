import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/order_service.dart';
import 'order_edit_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({required this.orderId, Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Map<String, dynamic>?> _orderFuture;

  @override
  void initState() {
    super.initState();
    // Debug: print the orderId
    // ignore: avoid_print
    print('[OrderDetailScreen] orderId: [32m${widget.orderId}[0m');
    _orderFuture = _getOrderDetailsWithDebug(widget.orderId);

  }

  Future<Map<String, dynamic>?> _getOrderDetailsWithDebug(int orderId) async {
    final order = await OrderService().getOrderDetails(orderId);
    // Debug: print the fetched order
    // ignore: avoid_print
    print('[OrderDetailScreen] fetched order: [36m$order[0m');
    return order;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.salesOrdersTitle),
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _orderFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) return SizedBox.shrink();
              final order = snapshot.data!;
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: localizations.edit,
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderEditScreen(order: order),
                    ),
                  );
                  if (updated == true) {
                    setState(() {
                      _orderFuture = OrderService().getOrderDetails(widget.orderId);
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(

        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            if (snapshot.hasError) {
              // ignore: avoid_print
              print('[OrderDetailScreen] snapshot error: \u001b[31m${snapshot.error}\u001b[0m');
            }
            return Center(child: Text(localizations.noOrdersFound));
          }
          final order = snapshot.data!;
          // Header fields
          final orderNumber = order['name'] ?? '';
          final partner = order['partner_id'] is List && order['partner_id'].length > 1 ? order['partner_id'][1] : '';
          final partnerAddress = order['partner_address'] ?? '';
          final orderDate = order['date_order'] != null
              ? DateFormat.yMMMd().add_jm().format(DateTime.parse(order['date_order']))
              : '';
          final paymentTerms = order['payment_term_id'] is List && order['payment_term_id'].length > 1 ? order['payment_term_id'][1] : '';
          final quotationTemplate = order['sale_order_template_id'] is List && order['sale_order_template_id'].length > 1 ? order['sale_order_template_id'][1] : '';
          final salesperson = order['user_id'] is List && order['user_id'].length > 1 ? order['user_id'][1] : '';
          final salesTeam = order['team_id'] is List && order['team_id'].length > 1 ? order['team_id'][1] : '';
          final company = order['company_id'] is List && order['company_id'].length > 1 ? order['company_id'][1] : '';
          final onlineSignature = order['require_signature'] == true ? localizations.enabled : (order['require_signature'] == false ? localizations.disabled : '');
          final onlinePayment = order['require_payment'] == true ? localizations.enabled : (order['require_payment'] == false ? localizations.disabled : '');
          final invoiceStatus = order['invoice_status'] ?? '';
          final deliveryStatus = order['delivery_status'] ?? '';
          final tracking = order['tracking_number'] ?? '';
          final orderLines = (order['order_lines'] as List?) ?? [];
          final currency = order['currency_id'] is List && order['currency_id'].length > 1 ? order['currency_id'][1] : 'DA';
          final untaxed = order['amount_untaxed'] ?? 0;
          final tax = order['amount_tax'] ?? 0;
          final total = order['amount_total'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Card Header
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('${localizations.number}: ', style: Theme.of(context).textTheme.titleMedium),
                              Text(orderNumber, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${localizations.customer}: $partner', style: Theme.of(context).textTheme.bodyLarge),
                                    if (partnerAddress != null && partnerAddress.toString().isNotEmpty)
                                      Text(partnerAddress.toString(), style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text('${localizations.orderDate}: $orderDate'),
                            ],
                          ),
                          if (paymentTerms != null && paymentTerms.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.payments, color: Theme.of(context).colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('${localizations.paymentTerms}: $paymentTerms'),
                              ],
                            ),
                          ],
                          if (quotationTemplate != null && quotationTemplate.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.description, color: Theme.of(context).colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('${localizations.quotationTemplate}: $quotationTemplate'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Additional Info Section
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (salesperson.toString().isNotEmpty)
                            Row(children: [Icon(Icons.account_circle, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.salesperson}: $salesperson')]),
                          if (salesTeam.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.group, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.salesTeam}: $salesTeam')]),
                          ],
                          if (company.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.business, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.company}: $company')]),
                          ],
                          if (onlineSignature.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.edit, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.onlineSignature}: $onlineSignature')]),
                          ],
                          if (onlinePayment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.payment, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.onlinePayment}: $onlinePayment')]),
                          ],
                          if (invoiceStatus.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.receipt, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.invoicing}: $invoiceStatus')]),
                          ],
                          if (deliveryStatus.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.local_shipping, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.delivery}: $deliveryStatus')]),
                          ],
                          if (tracking.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [Icon(Icons.track_changes, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('${localizations.tracking}: $tracking')]),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  // Order Lines Table
                  Text(localizations.orderLines, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text(localizations.product)),
                        DataColumn(label: Text(localizations.description)),
                        DataColumn(label: Text(localizations.quantity)),
                        DataColumn(label: Text(localizations.delivered)),
                        DataColumn(label: Text(localizations.invoiced)),
                        DataColumn(label: Text(localizations.unitOfMeasure)),
                        DataColumn(label: Text(localizations.price)),
                        DataColumn(label: Text(localizations.taxes)),
                        DataColumn(label: Text(localizations.subtotal)),
                      ],
                      rows: orderLines.map<DataRow>((line) {
                        final product = line['product_id'] is List && line['product_id'].length > 1 ? line['product_id'][1] : '';
                        final description = line['name'] ?? '';
                        final qty = line['product_uom_qty'] ?? 0;
                        final delivered = line['qty_delivered'] ?? 0;
                        final invoiced = line['qty_invoiced'] ?? 0;
                        final uom = line['product_uom'] is List && line['product_uom'].length > 1 ? line['product_uom'][1] : '';
                        final price = line['price_unit'] ?? 0;
                        final taxes = (line['tax_id'] is List && line['tax_id'].length > 1) ? line['tax_id'].sublist(1).join(', ') : '';
                        final subtotal = line['price_subtotal'] ?? 0;
                        return DataRow(cells: [
                          DataCell(Text(product.toString())),
                          DataCell(Text(description.toString())),
                          DataCell(Text(qty.toString())),
                          DataCell(Text(delivered.toString())),
                          DataCell(Text(invoiced.toString())),
                          DataCell(Text(uom.toString())),
                          DataCell(Text(NumberFormat.currency(symbol: currency).format(price))),
                          DataCell(Text(taxes.toString())),
                          DataCell(Text(NumberFormat.currency(symbol: currency).format(subtotal))),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer summary
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${localizations.untaxedAmount}: ' + NumberFormat.currency(symbol: currency).format(untaxed)),
                        Text('${localizations.vat}: ' + NumberFormat.currency(symbol: currency).format(tax)),
                        Text('${localizations.total}: ' + NumberFormat.currency(symbol: currency).format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}