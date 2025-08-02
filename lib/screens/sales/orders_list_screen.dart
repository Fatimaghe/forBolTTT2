import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderService().fetchOrders(fields: [
      'id', 'name', 'date_order', 'partner_id', 'user_id', 'activity_ids',
      'company_id', 'amount_total', 'invoice_status'
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.salesOrdersTitle)),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: localizations.searchOrders,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: Center(child: Text(localizations.noOrdersFound)),
                ),
              ],
            );
          }
          _allOrders.clear();
          for (final e in snapshot.data!) {
            if (e is Map<String, dynamic>) {
              _allOrders.add(e);
            } else {
              // ignore: avoid_print
              print('Skipping non-map order: ${e.runtimeType} value=$e');
            }
          }
          _filteredOrders = _searchQuery.isEmpty
              ? List<Map<String, dynamic>>.from(_allOrders)
              : _allOrders.where((order) {
                  final name = (order['name'] ?? '').toString().toLowerCase();
                  final partner = order['partner_id'] is List && order['partner_id'].length > 1
                      ? order['partner_id'][1].toString().toLowerCase()
                      : '';
                  final company = order['company_id'] is List && order['company_id'].length > 1
                      ? order['company_id'][1].toString().toLowerCase()
                      : '';
                  return name.contains(_searchQuery.toLowerCase()) ||
                      partner.contains(_searchQuery.toLowerCase()) ||
                      company.contains(_searchQuery.toLowerCase());
                }).toList();
          if (_filteredOrders.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: localizations.searchOrders,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: Center(child: Text(localizations.noOrdersFound)),
                ),
              ],
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: localizations.searchOrders,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, idx) {
                    final order = _filteredOrders[idx];
                    final orderId = order['id'];
                    if (orderId == null) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        color: Colors.red.shade100,
                        child: ListTile(
                          title: Text(localizations.orderMissingId, style: const TextStyle(color: Colors.red)),
                        ),
                      );
                    }
                    return OrderCard(
                      order: order,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(orderId: orderId),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  const OrderCard({required this.order, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (order is! Map<String, dynamic>) {
      // Defensive: show error card if not a map
      return Card(
        margin: const EdgeInsets.all(8),
        color: Colors.red.shade100,
        child: ListTile(
          title: Text(localizations.invalidOrderData, style: const TextStyle(color: Colors.red)),
          subtitle: Text('Type: ${order.runtimeType} value=$order'),
        ),
      );
    }
    final date = order['date_order'] != null
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(order['date_order']))
        : '';
    final total = NumberFormat.currency(locale: 'fr_DZ', symbol: 'DA').format(order['amount_total'] ?? 0);
    String partnerName = '';
    final partner = order['partner_id'];
    if (partner is List && partner.length > 1) partnerName = partner[1].toString();
    String userName = '';
    final user = order['user_id'];
    if (user is List && user.length > 1) userName = user[1].toString();
    String companyName = '';
    final company = order['company_id'];
    if (company is List && company.length > 1) companyName = company[1].toString();
    String activities = '';
    final acts = order['activity_ids'];
    if (acts is List && acts.isNotEmpty) activities = acts.join(', ');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order['name'] ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      partnerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(date, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      companyName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(total, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      userName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.receipt_long, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${localizations.invoiceStatus}: ${order['invoice_status'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              if (activities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_note, size: 16),
                    const SizedBox(width: 4),
                    Text('${localizations.activities}: $activities', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}