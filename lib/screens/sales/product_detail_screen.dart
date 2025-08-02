import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../models/product.dart';
import 'add_product_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? productImage;
    if (product.image.isNotEmpty) {
      try {
        productImage = base64Decode(product.image);
      } catch (_) {
        productImage = null;
      }
    }
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: localizations.editProduct,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(product: product),
                ),
              );
              if (result != null) {
                setState(() {
                  product = result;
                });
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
            // Product Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: productImage != null && productImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.inventory_2, size: 64, color: Colors.grey[600]);
                        },
                      ),
                    )
                  : Icon(Icons.inventory_2, size: 64, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Product Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.internalReference + ': ${product.defaultCode}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            localizations.salePrice,
                            NumberFormat.currency(symbol: 'DA ').format(product.listPrice),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            localizations.cost,
                            NumberFormat.currency(symbol: 'DA ').format(product.standardPrice),
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            localizations.onHand,
                            '${product.available}',
                            product.available > 0 ? Colors.blue : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Product Details Section with requested labels
            _buildSection(
              context,
              localizations.productInformation,
              [
                _buildInfoRow(Icons.category, localizations.category, product.categId != null ? product.categId.toString() : ''),
                _buildInfoRow(Icons.straighten, localizations.unitOfMeasure, product.uomName),
                _buildInfoRow(Icons.inventory, localizations.onHand, '${product.available}'),
                _buildInfoRow(Icons.trending_up, localizations.forecasted, '${product.forecasted}'),
                _buildInfoRow(Icons.arrow_downward, localizations.incomingQty, '${product.inQty}'),
                _buildInfoRow(Icons.arrow_upward, localizations.outgoingQty, '${product.outQty}'),
                _buildInfoRow(Icons.policy, localizations.invoicingPolicy, product.invoicingPolicy),
              ],
            ),

            const SizedBox(height: 16),

            // Description (hide if blank)
            if (product.description.trim().isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.available > 0 ? () {
                      // TODO: Add to cart or create order
                    } : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(localizations.addToOrder),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Update stock
                    },
                    icon: const Icon(Icons.inventory),
                    label: Text(localizations.updateStock),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
}