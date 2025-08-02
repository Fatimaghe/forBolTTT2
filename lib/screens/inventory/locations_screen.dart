import 'package:flutter/material.dart';
import '../../models/location.dart';
import '../../data/dummy_data.dart';
import 'add_location_screen.dart';
import 'location_detail_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Location> locations = [];
  List<Location> filteredLocations = [];
  String searchQuery = '';
  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() {
    // TODO: Load from Odoo API
    locations = DummyData.locations;
    _filterLocations();
  }

  void _filterLocations() {
    setState(() {
      filteredLocations = locations.where((location) {
        final matchesSearch = location.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            location.completeAddress.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesType = selectedType == 'All' || location.usage == selectedType.toLowerCase();
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = ['All', 'Internal', 'Customer', 'Supplier', 'Transit'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddLocationScreen()),
              );
              if (result != null) {
                _loadLocations();
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
                    hintText: 'Search locations...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterLocations();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: types.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              selectedType = type;
                            });
                            _filterLocations();
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
                    'Total Locations',
                    filteredLocations.length.toString(),
                    Icons.location_on,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Internal',
                    filteredLocations.where((l) => l.usage == 'internal').length.toString(),
                    Icons.warehouse,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'External',
                    filteredLocations.where((l) => l.usage != 'internal').length.toString(),
                    Icons.public,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Locations List
          Expanded(
            child: filteredLocations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No locations found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return _buildLocationCard(location);
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

  Widget _buildLocationCard(Location location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getUsageColor(location.usage).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getUsageIcon(location.usage),
            color: _getUsageColor(location.usage),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                location.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUsageColor(location.usage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                location.usage.toUpperCase(),
                style: TextStyle(
                  color: _getUsageColor(location.usage),
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
            Text(location.completeAddress),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Barcode: ${location.barcode}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
              builder: (context) => LocationDetailScreen(location: location),
            ),
          );
        },
      ),
    );
  }

  IconData _getUsageIcon(String usage) {
    switch (usage.toLowerCase()) {
      case 'internal':
        return Icons.warehouse;
      case 'customer':
        return Icons.person;
      case 'supplier':
        return Icons.business;
      case 'transit':
        return Icons.local_shipping;
      default:
        return Icons.location_on;
    }
  }

  Color _getUsageColor(String usage) {
    switch (usage.toLowerCase()) {
      case 'internal':
        return Colors.green;
      case 'customer':
        return Colors.blue;
      case 'supplier':
        return Colors.orange;
      case 'transit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}