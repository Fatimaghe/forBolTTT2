import 'package:flutter/material.dart';
import '../../models/customer.dart';
import 'add_customer_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/crm_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer customer;
  List<Customer> relatedIndividuals = [];

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    _loadRelatedIndividuals();
  }

  Future<void> _loadRelatedIndividuals() async {
    if (customer.customerType == 'company') {
      final crmService = CrmService();
      // Fetch only individuals related to this company from the server (preferably filtered server-side)
      final related = await crmService.getCustomers(parentId: customer.id, customerType: 'individual');
      setState(() {
        relatedIndividuals = related;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCustomerScreen(customer: customer),
                ),
              );
              if (result != null) {
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: l10n.delete,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.delete + ' ' + l10n.customers),
                  content: Text(l10n.areYouSureSignOut),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  final crmService = CrmService();
                  await crmService.deleteCustomerById(customer.id);
                  if (mounted) {
                    Navigator.pop(context, 'deleted');
                  }
                } catch (e) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.failed),
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
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
            // Customer Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (customer.customerType == 'individual' && customer.parentName != null && customer.parentName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('Company: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  customer.parentName!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(customer.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              customer.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(customer.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Information
            _buildSection(
              context,
              l10n.basicInformation,
              [
                _buildInfoRow(Icons.email, l10n.email, customer.email),
                _buildInfoRow(Icons.phone, l10n.phone, customer.phone),
              ],
            ),

            const SizedBox(height: 16),

            // Address Information
            _buildSection(
              context,
              l10n.addressInformation,
              [
                _buildInfoRow(Icons.location_on, l10n.address, customer.address),
                _buildInfoRow(Icons.location_city, l10n.city, customer.city),
                _buildInfoRow(Icons.public, l10n.country, customer.country),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Information
            _buildSection(
              context,
              l10n.additionalInformation,
              [
                _buildInfoRow(
                  Icons.calendar_today,
                  l10n.created,
                  DateFormat('MMM dd, yyyy').format(customer.createdAt),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Call customer
                    },
                    icon: const Icon(Icons.phone),
                    label: Text(l10n.phone),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Email customer
                    },
                    icon: const Icon(Icons.email),
                    label: Text(l10n.email),
                  ),
                ),
              ],
            ),

            // Related individuals for companies
            if (customer.customerType == 'company') ...[
              const SizedBox(height: 32),
              ExpansionTile(
                title: Text(l10n.individual),
                initiallyExpanded: false,
                children: relatedIndividuals.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.noDataFound, style: TextStyle(color: Colors.grey[600])),
                        ),
                      ]
                    : relatedIndividuals
                        .map((individual) => ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(individual.name),
                              subtitle: Text(individual.email),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerDetailScreen(customer: individual),
                                  ),
                                );
                                if (result == 'deleted') {
                                  Navigator.pop(context, 'deleted');
                                }
                              },
                            ))
                        .toList(),
              ),
            ],
          ],
        ),
      ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'prospect':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}