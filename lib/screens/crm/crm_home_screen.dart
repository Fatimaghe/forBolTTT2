import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/action_card.dart';
import '../../widgets/stat_card.dart';

import 'customers_screen.dart';
import 'opportunities_screen.dart';
import '../../services/crm_service.dart';

class CrmHomeScreen extends StatelessWidget {
  const CrmHomeScreen({super.key});

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
                    Color(0xFF1F77B4),
                    Color(0xFF4A90E2),
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
                          'assets/images/icons/crm.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.people_alt,
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
                              l10n.crm,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.customerRelationshipManagement,
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
            FutureBuilder<List>(
              future: CrmService().getCustomers(customerType: 'all'),
              builder: (context, snapshot) {
                final total = snapshot.hasData ? snapshot.data!.length.toString() : '';
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: l10n.totalCustomers,
                        value: total,
                        icon: Icons.people_alt,
                        color: const Color(0xFF1F77B4), // blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: l10n.activeOpportunities,
                        value: '56',
                        icon: Icons.track_changes,
                        color: const Color(0xFF2CA02C),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: l10n.revenuePipeline,
                    value: '\$245K',
                    icon: Icons.trending_up,
                    color: const Color(0xFF9467BD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: l10n.conversionRate,
                    value: '23%',
                    icon: Icons.analytics,
                    color: const Color(0xFFFF7F0E),
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
              title: l10n.customers,
              subtitle: l10n.manageCustomerRelationships,
              icon: Icons.people_alt,
              color: const Color(0xFF1F77B4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersScreen()),
                );
              },
            ),

            ActionCard(
              title: l10n.opportunities,
              subtitle: l10n.trackSalesOpportunities,
              icon: Icons.track_changes,
              color: const Color(0xFF2CA02C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OpportunitiesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}