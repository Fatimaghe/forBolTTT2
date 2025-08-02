import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import '../purchasing/purchase_orders_screen.dart';
import 'invoices_screen.dart';
import 'payments_screen.dart'; // Add this import
// import 'purchase_orders_screen.dart'; // Uncomment when you create this screen

class InvoicingHomeScreen extends StatelessWidget {
  const InvoicingHomeScreen({super.key});

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
                    Color(0xFFFF7F0E),
                    Color(0xFFFF9800),
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
                              Icons.receipt_long,
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
                              l10n.invoicing,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.invoiceManagement,
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
                    title: l10n.totalInvoiced,
                    value: '\$89K',
                    icon: Icons.receipt_long,
                    color: const Color(0xFF1F77B4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.outstanding,
                    value: '\$23K',
                    icon: Icons.pending,
                    color: const Color(0xFFFF7F0E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: l10n.overdue,
                    value: '\$5K',
                    icon: Icons.warning,
                    color: const Color(0xFFD62728),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.paidThisMonth,
                    value: '\$67K',
                    icon: Icons.check_circle,
                    color: const Color(0xFF2CA02C),
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
              title: l10n.invoices,
              subtitle: l10n.createAndManageInvoices,
              icon: Icons.receipt_long,
              color: const Color(0xFF1F77B4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InvoicesScreen()),
                );
              },
            ),

            ActionCard(
              title: l10n.payments,
              subtitle: l10n.trackPaymentStatus,
              icon: Icons.payment,
              color: const Color(0xFF2CA02C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentsScreen()),
                );
              },
            ),

            ActionCard(
              title: l10n.purchaseOrders,
              subtitle: l10n.managePurchaseOrders,
              icon: Icons.shopping_bag,
              color: const Color(0xFF9467BD),
              onTap: () {
                // TODO: Uncomment when you create PurchaseOrdersScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseOrdersScreen()),);


              },
            ),
          ],
        ),
      ),
    );
  }
}