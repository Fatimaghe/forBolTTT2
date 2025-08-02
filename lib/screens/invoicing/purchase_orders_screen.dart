import 'package:flutter/material.dart';
import '../../models/purchase_order.dart';
import '../../data/dummy_data.dart';
//import 'purchase_order_detail_screen.dart';
//import 'add_purchase_order_screen.dart';
import 'package:intl/intl.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  List<PurchaseOrder> purchaseOrders = [];
  List<PurchaseOrder> filteredPurchaseOrders = [];
  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadPurchaseOrders();
  }

  void _loadPurchaseOrders() {
    // TODO: Load from Odoo API
    purchaseOrders = DummyData.purchaseOrders;
    _filterPurchaseOrders();
  }

  void _filterPurchaseOrders() {
    setState(() {
      filteredPurchaseOrders = purchaseOrders.where((order) {
        final matchesSearch = order.number.toLowerCase().contains(searchQuery.toLowerCase()) ||
            order.supplierName.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesStatus = selectedStatus == 'All' || order.status == selectedStatus.toLowerCase();
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
            //  final result = await Navigator.push(
                //context,
              //  MaterialPageRoute(builder: (context) => const AddPurchaseOrderScreen()),
            //  );
            //  if (result != null) {
             //   _loadPurchaseOrders();
             // }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search purchase orders...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterPurchaseOrders();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Draft', 'Sent', 'Confirmed', 'Done', 'Cancelled'].map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatus = status;
                            });
                            _filterPurchaseOrders();
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
                    'Total Orders',
                    filteredPurchaseOrders.length.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Amount',
                    NumberFormat.currency(symbol: '\$').format(
                      filteredPurchaseOrders.fold(0.0, (sum, order) => sum + order.totalAmount),
                    ),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    filteredPurchaseOrders.where((o) => o.status == 'sent').length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Purchase Orders List
          Expanded(
            child: filteredPurchaseOrders.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No purchase orders found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredPurchaseOrders.length,
              itemBuilder: (context, index) {
                final order = filteredPurchaseOrders[index];
                return _buildPurchaseOrderCard(order);
              },
            ),
          ),
        ],
      ),
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

  Widget _buildPurchaseOrderCard(PurchaseOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: _getStatusColor(order.status),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                order.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(order.status),
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
            Text(order.supplierName),
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
                        NumberFormat.currency(symbol: '\$').format(order.totalAmount),
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
                        'Order Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.orderDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          //Navigator.push(
          //  context,
          //  MaterialPageRoute(
          //    builder: (context) => PurchaseOrderDetailScreen(purchaseOrder: order),
          //  ),
         // );
        },
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
