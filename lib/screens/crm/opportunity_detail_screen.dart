import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../models/customer.dart';
import '../../services/crm_service.dart';
import 'add_opportunity_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:html/parser.dart' as html_parser;

class OpportunityDetailScreen extends StatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  String _stripHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty && value.trim() != '-';
    return true;
  }

  bool _hasAny(List<dynamic> values) {
    for (var v in values) {
      if (_hasValue(v)) return true;
    }
    return false;
  }

  late Opportunity opportunity;
  Customer? customer;
  bool detailsExpanded = true;

  @override
  void initState() {
    super.initState();
    opportunity = widget.opportunity;
    _fetchCustomer();
  }

  Future<void> _fetchCustomer() async {
    if (opportunity.customerId.isNotEmpty) {
      final crmService = CrmService();
      final cust = await crmService.getCustomerById(int.tryParse(opportunity.customerId) ?? 0);
      setState(() {
        customer = cust;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.opportunityDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOpportunityScreen(opportunity: opportunity),
                ),
              );
              if (result != null) {
                setState(() {
                  opportunity = result;
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
            // Opportunity Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStageColor(opportunity.stage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.track_changes,
                            color: _getStageColor(opportunity.stage),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opportunity.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opportunity.customerName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (customer != null && customer!.email.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer!.email,
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              if (customer != null && customer!.phone.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer!.phone,
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (opportunity.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: opportunity.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: TextStyle(color: Colors.blue[900]),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            l10n.expectedRevenue,
                            NumberFormat.currency(symbol: '\$').format(opportunity.expectedRevenue),
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            l10n.probability,
                            '${opportunity.probability}%',
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stage Progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStageProgress(context),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expandable Details Section
            ExpansionTile(
              title: Text(l10n.moreDetails, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              initiallyExpanded: detailsExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  detailsExpanded = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Information
                      if (_hasValue(opportunity.customerName)) ...[
                        Text(l10n.basicInformation, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        const SizedBox(height: 6),
                        if (_hasValue(opportunity.customerName)) _buildInfoRow(Icons.person, l10n.customerName, opportunity.customerName),
                        if (_hasValue(opportunity.email) || _hasValue(customer?.email)) _buildInfoRow(Icons.email, l10n.email, opportunity.email.isNotEmpty ? opportunity.email : (customer?.email ?? '-')),
                        if (_hasValue(opportunity.phone) || _hasValue(customer?.phone)) _buildInfoRow(Icons.phone, l10n.phone, opportunity.phone.isNotEmpty ? opportunity.phone : (customer?.phone ?? '-')),
                        if (_hasValue(opportunity.mobile)) _buildInfoRow(Icons.phone_android, l10n.mobile, opportunity.mobile),
                        if (_hasValue(customer?.address)) _buildInfoRow(Icons.location_on, l10n.address, customer?.address ?? '-'),
                        if (_hasValue(opportunity.company)) _buildInfoRow(Icons.business, l10n.company, opportunity.company),
                        if (_hasValue(opportunity.jobPosition)) _buildInfoRow(Icons.work, l10n.jobPosition, opportunity.jobPosition),
                        if (_hasValue(opportunity.country)) _buildInfoRow(Icons.flag, l10n.country, opportunity.country),
                        if (_hasValue(opportunity.city)) _buildInfoRow(Icons.location_city, l10n.city, opportunity.city),
                        if (_hasValue(opportunity.stateName)) _buildInfoRow(Icons.map, l10n.state, opportunity.stateName),
                        if (_hasValue(opportunity.zipCode)) _buildInfoRow(Icons.markunread_mailbox, l10n.zipCode, opportunity.zipCode),
                        const SizedBox(height: 12),
                      ],
                      // Marketing Details
                      if (_hasAny([
                        opportunity.campaign,
                        opportunity.source,
                        opportunity.medium,
                        opportunity.referredBy,
                        opportunity.industry,
                        customer?.industry,
                        opportunity.website,
                        customer?.website,
                        opportunity.priority,
                        opportunity.type,
                        opportunity.function,
                      ])) ...[
                        Text(l10n.additionalInformation, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
                        const SizedBox(height: 6),
                        if (_hasValue(opportunity.campaign)) _buildInfoRow(Icons.campaign, l10n.campaign, opportunity.campaign),
                        if (_hasValue(opportunity.source)) _buildInfoRow(Icons.source, l10n.source, opportunity.source),
                        if (_hasValue(opportunity.medium)) _buildInfoRow(Icons.emoji_objects, l10n.medium, opportunity.medium),
                        if (_hasValue(opportunity.referredBy)) _buildInfoRow(Icons.person_add, l10n.referredBy, opportunity.referredBy),
                        if (_hasValue(opportunity.industry) || _hasValue(customer?.industry)) _buildInfoRow(Icons.business, l10n.industry, opportunity.industry.isNotEmpty ? opportunity.industry : (customer?.industry ?? '-')),
                        if (_hasValue(opportunity.website) || _hasValue(customer?.website)) _buildInfoRow(Icons.web, l10n.website, opportunity.website.isNotEmpty ? opportunity.website : (customer?.website ?? '-')),
                        if (_hasValue(opportunity.priority)) _buildInfoRow(Icons.priority_high, l10n.priority, opportunity.priority),
                        if (_hasValue(opportunity.type)) _buildInfoRow(Icons.info, l10n.type, opportunity.type),
                        if (_hasValue(opportunity.function)) _buildInfoRow(Icons.work_outline, l10n.function, opportunity.function),
                        const SizedBox(height: 12),
                      ],
                      // Tracking Details
                      if (_hasAny([
                        opportunity.salesTeam,
                        opportunity.salesPerson,
                        opportunity.expectedCloseDate,
                        opportunity.createdAt,
                        opportunity.daysToAssign != 0 ? opportunity.daysToAssign.toString() : '',
                        opportunity.daysToClose != 0 ? opportunity.daysToClose.toString() : '',
                      ])) ...[
                        Text(l10n.trackingDetails ?? 'Tracking Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900])),
                        const SizedBox(height: 6),
                        if (_hasValue(opportunity.salesTeam)) _buildInfoRow(Icons.group, l10n.salesTeam, opportunity.salesTeam),
                        if (_hasValue(opportunity.salesPerson)) _buildInfoRow(Icons.person, l10n.salesPerson, opportunity.salesPerson),
                        _buildInfoRow(Icons.calendar_today, l10n.expectedCloseDate, DateFormat('MMM dd, yyyy').format(opportunity.expectedCloseDate)),
                        _buildInfoRow(Icons.access_time, l10n.created, DateFormat('MMM dd, yyyy').format(opportunity.createdAt)),
                        if (opportunity.daysToAssign != 0) _buildInfoRow(Icons.timelapse, l10n.daysToAssign ?? 'Days to Assign', opportunity.daysToAssign.toString()),
                        if (opportunity.daysToClose != 0) _buildInfoRow(Icons.timelapse, l10n.daysToClose ?? 'Days to Close', opportunity.daysToClose.toString()),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (_stripHtml(opportunity.description).replaceAll(RegExp(r'[\s\u00A0]+'), '').isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stripHtml(opportunity.description),
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
                    onPressed: () {
                      // TODO: Update stage
                    },
                    icon: const Icon(Icons.update),
                    label: Text(l10n.stage),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add activity
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.add),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildStageProgress(BuildContext context) {
    final stages = ['Qualified', 'Proposition', 'Negotiation', 'Won'];
    final currentStageIndex = stages.indexWhere(
      (stage) => stage.toLowerCase() == opportunity.stage.toLowerCase(),
    );

    return Row(
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        // final stage = entry.value; // Removed unused variable
        final isActive = index <= currentStageIndex;
        final isCurrent = index == currentStageIndex;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? _getStageColor(opportunity.stage) : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: isCurrent
                    ? Icon(
                        Icons.radio_button_checked,
                        color: Colors.white,
                        size: 16,
                      )
                    : isActive
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
              ),
              if (index < stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? _getStageColor(opportunity.stage) : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // _buildSection removed (was unused)

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

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'qualified':
        return Colors.blue;
      case 'proposition':
        return Colors.orange;
      case 'negotiation':
        return Colors.purple;
      case 'won':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}