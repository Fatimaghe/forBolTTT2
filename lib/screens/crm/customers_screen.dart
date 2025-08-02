import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../services/crm_service.dart';
import 'customer_detail_screen.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CrmService _crmService = CrmService();
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  int globalCustomerCount = 0;
  List<Customer> allCustomers = [];
  String searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String customerTypeFilter = 'company'; // 'company' or 'individual'

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Always fetch the global total (all customers, no filter)
      final all = await _crmService.getCustomers(customerType: 'all');
      globalCustomerCount = all.length;
      allCustomers = all;

      // Then fetch the filtered list for display
      final loadedCustomers = await _crmService.getCustomers(
        searchTerm: searchQuery.isEmpty ? null : searchQuery,
        customerType: customerTypeFilter,
      );
      setState(() {
        customers = loadedCustomers;
        filteredCustomers = loadedCustomers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });

    // Debounce the search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery == query) {
        _loadCustomers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    int companiesCount = allCustomers.where((c) => c.customerType == 'company').length;
    int individualsCount = allCustomers.where((c) => c.customerType == 'individual').length;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
              );
              if (result != null) {
                _loadCustomers();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.search + ' ' + l10n.customers + '...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        customerTypeFilter = 'company';
                        _loadCustomers();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: customerTypeFilter == 'company' ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: customerTypeFilter == 'company' ? Theme.of(context).colorScheme.primary : Colors.grey[400]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business, color: customerTypeFilter == 'company' ? Colors.white : Colors.blue[700], size: 20),
                          const SizedBox(width: 6),
                          Text(
                            l10n.company,
                            style: TextStyle(
                              color: customerTypeFilter == 'company' ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$companiesCount',
                            style: TextStyle(
                              color: customerTypeFilter == 'company' ? Colors.white : Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        customerTypeFilter = 'individual';
                        _loadCustomers();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: customerTypeFilter == 'individual' ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: customerTypeFilter == 'individual' ? Theme.of(context).colorScheme.primary : Colors.grey[400]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: customerTypeFilter == 'individual' ? Colors.white : Colors.blue[700], size: 20),
                          const SizedBox(width: 6),
                          Text(
                            l10n.individual,
                            style: TextStyle(
                              color: customerTypeFilter == 'individual' ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$individualsCount',
                            style: TextStyle(
                              color: customerTypeFilter == 'individual' ? Colors.white : Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildCustomersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList() {
    final l10n = AppLocalizations.of(context);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              l10n.error + ' ' + l10n.customers,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomers,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noDataFound, style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        final displayName = (customer.name.isNotEmpty && customer.name != 'false') ? customer.name : l10n.name;
        final displayEmail = (customer.email.isNotEmpty && customer.email != 'false') ? customer.email : '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                displayName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: displayEmail.isNotEmpty
                ? Text(displayEmail)
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(customer.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                customer.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(customer.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetailScreen(customer: customer),
                ),
              );
              if (result == 'deleted') {
                _loadCustomers();
              }
            },
          ),
        );
      },
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