import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../data/dummy_data.dart';
import 'add_payment_screen.dart';
import 'payment_detail_screen.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> payments = [];
  List<Payment> filteredPayments = [];
  String searchQuery = '';
  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    // TODO: Load from Odoo API
    payments = [];
    _filterPayments();
  }

  void _filterPayments() {
    setState(() {
      filteredPayments = payments.where((payment) {
        final matchesSearch = payment.reference.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.partnerName.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesType = selectedType == 'All' || payment.paymentType == selectedType.toLowerCase();
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
              );
              if (result != null) {
                _loadPayments();
              }
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
                    hintText: 'Search payments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterPayments();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Inbound', 'Outbound'].map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              selectedType = type;
                            });
                            _filterPayments();
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
                    'Total Payments',
                    filteredPayments.length.toString(),
                    Icons.payment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Amount',
                    NumberFormat.currency(symbol: '\$').format(
                      filteredPayments.fold(0.0, (sum, payment) => sum + payment.amount),
                    ),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    filteredPayments.where((p) => 
                      p.paymentDate.month == DateTime.now().month &&
                      p.paymentDate.year == DateTime.now().year
                    ).length.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payments List
          Expanded(
            child: filteredPayments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No payments found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return _buildPaymentCard(payment);
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

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTypeColor(payment.paymentType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            payment.paymentType == 'inbound' ? Icons.arrow_downward : Icons.arrow_upward,
            color: _getTypeColor(payment.paymentType),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                payment.reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStateColor(payment.state).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                payment.state.toUpperCase(),
                style: TextStyle(
                  color: _getStateColor(payment.state),
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
            Text(payment.partnerName),
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
                        NumberFormat.currency(symbol: '\$').format(payment.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(payment.paymentType),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(payment.paymentDate),
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
                        'Method',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        payment.paymentMethod,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailScreen(payment: payment),
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'inbound':
        return Colors.green;
      case 'outbound':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'posted':
        return Colors.blue;
      case 'sent':
        return Colors.orange;
      case 'reconciled':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}