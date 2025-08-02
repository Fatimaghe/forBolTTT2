import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../l10n/app_localizations.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Helper to decode base64 image string
  Uint8List _decodeBase64(String base64String) {
    try {
      return base64String.isNotEmpty
          ? base64Decode(base64String)
          : Uint8List.fromList([]);
    } catch (_) {
      return Uint8List.fromList([]);
    }
  }
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final productService = ProductService();
      final rawProducts = await productService.fetchProducts();
      print('DEBUG: rawProducts from Odoo:');
      print(rawProducts);
      for (var p in rawProducts) {
        print('DEBUG: Single product raw data: $p');
      }
      products = rawProducts.map((p) => Product(
        id: p['id']?.toString() ?? '',
        name: p['name'] ?? '',
        defaultCode: p['default_code'] is String
            ? p['default_code']
            : (p['default_code'] == false || p['default_code'] == true || p['default_code'] == null
                ? ''
                : p['default_code'].toString()),
        description: p['description'] ?? '',
        categId: p['categ_id'] is List && p['categ_id'].isNotEmpty
            ? p['categ_id'][0] as int
            : (p['categ_id'] is int ? p['categ_id'] : int.tryParse(p['categ_id']?.toString() ?? '')),
        standardPrice: p['standard_price'] is num
            ? p['standard_price'].toDouble()
            : (p['standard_price'] is String ? double.tryParse(p['standard_price']) ?? 0.0 : 0.0),
        listPrice: p['list_price'] is num
            ? p['list_price'].toDouble()
            : (p['list_price'] is String ? double.tryParse(p['list_price']) ?? 0.0 : 0.0),
        canBeSold: p['sale_ok'] is bool
            ? p['sale_ok']
            : (p['sale_ok'] == 1 ? true : false),
        canBePurchased: p['purchase_ok'] is bool
            ? p['purchase_ok']
            : (p['purchase_ok'] == 1 ? true : false),
        productType: p['type'] is String
            ? p['type']
            : (p['type'] == false || p['type'] == true || p['type'] == null ? '' : p['type'].toString()),
        uomId: p['uom_id'] is List && p['uom_id'].isNotEmpty
            ? p['uom_id'][0] as int
            : (p['uom_id'] is int ? p['uom_id'] : int.tryParse(p['uom_id']?.toString() ?? '')),
        uomName: p['uom_id'] is List && p['uom_id'].length > 1
            ? p['uom_id'][1].toString()
            : '',
        barcode: p['barcode'] is String
            ? p['barcode']
            : (p['barcode'] == false || p['barcode'] == true || p['barcode'] == null ? '' : p['barcode'].toString()),
        weight: p['weight'] is num
            ? p['weight'].toDouble()
            : (p['weight'] is String ? double.tryParse(p['weight']) ?? 0.0 : 0.0),
        image: p['image_128'] is String
            ? p['image_128']
            : '',
        createdAt: DateTime.now(),
        available: p['qty_available'] is num
            ? p['qty_available'].toInt()
            : (p['qty_available'] is String ? int.tryParse(p['qty_available']) ?? 0 : 0),
        inStock: p['in_stock'] is num
            ? p['in_stock'].toInt()
            : (p['in_stock'] is String ? int.tryParse(p['in_stock']) ?? 0 : 0),
        reserved: p['reserved'] is num
            ? p['reserved'].toInt()
            : (p['reserved'] is String ? int.tryParse(p['reserved']) ?? 0 : 0),
        forecasted: p['virtual_available'] is num
            ? p['virtual_available'].toInt()
            : (p['virtual_available'] is String ? int.tryParse(p['virtual_available']) ?? 0 : 0),
        inQty: p['incoming_qty'] is num
            ? p['incoming_qty'].toInt()
            : (p['incoming_qty'] is String ? int.tryParse(p['incoming_qty']) ?? 0 : 0),
        outQty: p['outgoing_qty'] is num
            ? p['outgoing_qty'].toInt()
            : (p['outgoing_qty'] is String ? int.tryParse(p['outgoing_qty']) ?? 0 : 0),
        sold: p['sold_qty'] is num
            ? p['sold_qty'].toInt()
            : (p['sold_qty'] is String ? int.tryParse(p['sold_qty']) ?? 0 : 0),
        customerTaxes: p['taxes_id'] is List && p['taxes_id'].length > 1
            ? p['taxes_id'][1].toString()
            : (p['taxes_id'] == false || p['taxes_id'] == true || p['taxes_id'] == null ? '' : p['taxes_id'].toString()),
        invoicingPolicy: p['invoice_policy'] is String
            ? p['invoice_policy']
            : (p['invoice_policy'] == false || p['invoice_policy'] == true || p['invoice_policy'] == null ? '' : p['invoice_policy'].toString()),
      )).toList();
      _filterProducts(searchQuery);
      if (products.isEmpty) {
        errorMessage = 'No products found.';
      }
    } catch (e, stack) {
      print('ERROR: Failed to load products: $e');
      print(stack);
      errorMessage = 'Failed to load products: '
        + (e is Exception ? e.toString() : 'Unknown error');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.defaultCode.toLowerCase().contains(query.toLowerCase()) ||
                (product.categId != null && product.categId.toString().toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: localizations.addProduct,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(),
                ),
              );
              if (result != null && result is Product) {
                // Optionally reload products after adding
                _loadProducts();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: _filterProducts,
                        decoration: InputDecoration(
                          labelText: localizations.search + ' ' + localizations.products,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(child: Text(localizations.noProductsToDisplay))
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailScreen(product: product),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          product.image.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.memory(
                                                    _decodeBase64(product.image),
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 6),
                                                if (product.listPrice > 0)
                                                  Text(localizations.price + ': ' + NumberFormat.simpleCurrency().format(product.listPrice),
                                                      style: Theme.of(context).textTheme.bodyMedium),
                                                if (product.defaultCode.isNotEmpty)
                                                  Text(localizations.sku + ': ' + product.defaultCode,
                                                      style: Theme.of(context).textTheme.bodySmall),
                                                if (product.categId != null)
                                                  Text(localizations.category + ': ' + product.categId.toString(),
                                                      style: Theme.of(context).textTheme.bodySmall),
                                                if (product.weight > 0)
                                                  Text(localizations.weight + ': ${product.weight}',
                                                      style: Theme.of(context).textTheme.bodySmall),
                                                if (product.canBeSold)
                                                  Text(localizations.onHand + ': ${product.available}',
                                                      style: Theme.of(context).textTheme.bodySmall),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}