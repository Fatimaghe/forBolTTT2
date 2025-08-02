import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import 'quotations_screen.dart';
import 'orders_list_screen.dart';
import 'products_screen.dart';

class SalesHomeScreen extends StatelessWidget {
  const SalesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2CA02C),
                    Color(0xFF4CAF50),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/icons/sales.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 28,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sales,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.salesManagement,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.overview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: l10n.monthlySales,
                    value: '\$125K',
                    icon: Icons.trending_up,
                    color: const Color(0xFF2CA02C),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.activeOrders,
                    value: '89',
                    icon: Icons.shopping_cart,
                    color: const Color(0xFF1F77B4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: l10n.pendingQuotes,
                    value: '23',
                    icon: Icons.description,
                    color: const Color(0xFFFF7F0E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.products,
                    value: '456',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF9467BD),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            ActionCard(
              title: l10n.quotations,
              subtitle: l10n.createAndManageQuotations,
              icon: Icons.description,
              color: const Color(0xFFFF7F0E),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuotationsScreen()),
                );
              },
            ),

            ActionCard(
              title: l10n.orders,
              subtitle: l10n.trackSalesOrders,
              icon: Icons.shopping_cart,
              color: const Color(0xFF1F77B4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersListScreen()),
                );
              },
            ),

            ActionCard(
              title: l10n.products,
              subtitle: l10n.manageProductCatalog,
              icon: Icons.inventory_2,
              color: const Color(0xFF9467BD),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}