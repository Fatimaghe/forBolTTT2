import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../../data/dummy_data.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    // TODO: Load from Odoo API
    contacts = DummyData.contacts;
    _filterContacts();
  }

  void _filterContacts() {
    setState(() {
      filteredContacts = contacts.where((contact) {
        final matchesSearch = contact.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            contact.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            contact.company.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesFilter = true;
        switch (selectedFilter) {
          case 'Customers':
            matchesFilter = contact.isCustomer;
            break;
          case 'Suppliers':
            matchesFilter = contact.isSupplier;
            break;
          case 'All':
          default:
            matchesFilter = true;
            break;
        }

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddContactScreen()),
              );
              if (result != null) {
                _loadContacts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search contacts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterContacts();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Customers', 'Suppliers'].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                            _filterContacts();
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
                    'Total Contacts',
                    filteredContacts.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Customers',
                    filteredContacts.where((c) => c.isCustomer).length.toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Suppliers',
                    filteredContacts.where((c) => c.isSupplier).length.toString(),
                    Icons.business,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contacts List
          Expanded(
            child: filteredContacts.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No contacts found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return _buildContactCard(contact);
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

  Widget _buildContactCard(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (contact.isCustomer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (contact.isCustomer && contact.isSupplier)
                  const SizedBox(width: 4),
                if (contact.isSupplier)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'S',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contact.jobTitle.isNotEmpty ? contact.jobTitle : 'No job title',
              style: TextStyle(
                color: contact.jobTitle.isNotEmpty ? Colors.black87 : Colors.grey[500],
              ),
            ),
            Text(
              contact.company,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    contact.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  contact.phone.isNotEmpty ? contact.phone : 'No phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: contact.phone.isNotEmpty ? () {
                // TODO: Implement call functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${contact.phone}')),
                );
              } : null,
            ),
            IconButton(
              icon: const Icon(Icons.email, color: Colors.blue),
              onPressed: () {
                // TODO: Implement email functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Emailing ${contact.email}')),
                );
              },
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailScreen(contact: contact),
            ),
          );
          if (result != null) {
            _loadContacts();
          }
        },
      ),
    );
  }
}