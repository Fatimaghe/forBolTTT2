import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import 'inventory_screen.dart';
import 'locations_screen.dart';
import 'transfers_screen.dart';
import 'receipts_screen.dart';
import 'deliveries_screen.dart';

class InventoryHomeScreen extends StatelessWidget {
  const InventoryHomeScreen({super.key});

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
                    Color(0xFFD62728),
                    Color(0xFFE53935),
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
                          'assets/images/icons/inventory.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory_2,
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
                              l10n.inventory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.inventoryLogisticsManagement,
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
                    title: l10n.totalProducts,
                    value: '456',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF1F77B4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.lowStock,
                    value: '12',
                    icon: Icons.warning,
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
                    title: l10n.pendingTransfers,
                    value: '8',
                    icon: Icons.swap_horiz,
                    color: const Color(0xFF9467BD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.locations,
                    value: '5',
                    icon: Icons.location_on,
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
              title: l10n.inventory,
              subtitle: l10n.viewAndManageStockLevels,
              icon: Icons.inventory,
              color: const Color(0xFF1F77B4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: l10n.locations,
              subtitle: l10n.manageWarehouseLocations,
              icon: Icons.location_on,
              color: const Color(0xFF2CA02C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationsScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: l10n.transfers,
              subtitle: l10n.stockTransfersBetweenLocations,
              icon: Icons.swap_horiz,
              color: const Color(0xFF9467BD),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransfersScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: l10n.receipts,
              subtitle: l10n.incomingStockReceipts,
              icon: Icons.input,
              color: const Color(0xFF8C564B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceiptsScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: l10n.deliveries,
              subtitle: l10n.outgoingDeliveries,
              icon: Icons.local_shipping,
              color: const Color(0xFFE377C2),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveriesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}