import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/opportunity.dart';
import '../../services/crm_service.dart';
import 'opportunity_detail_screen.dart';
import 'add_opportunity_screen.dart';
import 'package:intl/intl.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final CrmService _crmService = CrmService();
  List<Opportunity> opportunities = [];
  List<Opportunity> filteredOpportunities = [];
  List<Map<String, dynamic>> stages = [];
  String selectedStage = '';
  String searchQuery = '';
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() { isLoading = true; });
    try {
      final fetchedStages = await _crmService.getOpportunityStages();
      setState(() {
        stages = fetchedStages;
        selectedStage = '';
      });
    } catch (e) {
      setState(() { errorMessage = 'Failed to load stages: \\${e.toString()}'; });
    }
    await _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final loadedOpportunities = await _crmService.getOpportunities(
        searchTerm: searchQuery.isEmpty ? null : searchQuery,
      );
      // For each opportunity, reload from Odoo to get the real probability
      final List<Opportunity> updatedOpportunities = [];
      for (final opp in loadedOpportunities) {
        try {
          final realOpp = await _crmService.getOpportunityById(int.parse(opp.id));
          if (realOpp != null) {
            updatedOpportunities.add(realOpp);
          } else {
            updatedOpportunities.add(opp);
          }
        } catch (e) {
          updatedOpportunities.add(opp);
        }
      }
      setState(() {
        opportunities = updatedOpportunities;
        filteredOpportunities = selectedStage.isEmpty
            ? updatedOpportunities
            : updatedOpportunities.where((o) => o.stage == selectedStage).toList();
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery == query) {
        _loadOpportunities();
      }
    });
  }

  void _onStageSelected(String stageName) {
    setState(() {
      selectedStage = stageName;
      filteredOpportunities = selectedStage.isEmpty
          ? opportunities
          : opportunities.where((o) => o.stage == selectedStage).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build unique stage list if backend returns nothing
    List<String> stageNames = [];
    if (stages.isNotEmpty) {
      stageNames = stages.map((s) => s['name'] as String? ?? '').where((s) => s.isNotEmpty).toSet().toList();
    } else {
      // Fallback: get unique stages from opportunities
      stageNames = opportunities.map((o) => o.stage).where((s) => s.isNotEmpty).toSet().toList();
      stageNames.sort();
    }

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.opportunities),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddOpportunityScreen()),
              );
              if (result != null) {
                _loadOpportunities();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOpportunities,
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
                hintText: l10n.search + ' ' + l10n.opportunities + '...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('All'),
                    selected: selectedStage.isEmpty,
                    onSelected: (_) => _onStageSelected(''),
                  ),
                ),
                if (stageNames.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(l10n.noDataFound),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ...stageNames.map((stageName) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(stageName),
                        selected: selectedStage == stageName,
                        onSelected: (_) => _onStageSelected(stageName),
                      ),
                    )),
              ],
            ),
          ),
          // Removed red note about no stages loaded from backend
          Expanded(
            child: _buildOpportunitiesGroupedByStage(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesGroupedByStage() {
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
              l10n.error + ' ' + l10n.opportunities,
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
              onPressed: _loadOpportunities,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    List<Opportunity> displayList;
    String? emptyMessage;
    if (selectedStage.isEmpty) {
      displayList = opportunities;
      emptyMessage = l10n.noDataFound;
    } else {
      displayList = opportunities.where((o) => o.stage == selectedStage).toList();
      emptyMessage = l10n.noDataFound;
    }
    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage!, style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) => _buildOpportunityCard(displayList[index], l10n),
    );
  }

  Widget _buildStageHeader(String stage) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _getStageColor(stage).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        stage.isEmpty ? 'No Stage' : stage,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _getStageColor(stage),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(Opportunity opportunity, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        tileColor: _getStageColor(opportunity.stage).withOpacity(0.1),
        leading: CircleAvatar(
          backgroundColor: _getStageColor(opportunity.stage),
          child: Text(opportunity.title.isNotEmpty ? opportunity.title[0].toUpperCase() : '?'),
        ),
        title: Text(
          opportunity.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opportunity.customerName),
            Text(
              '${NumberFormat.currency(symbol: '\$').format(opportunity.expectedRevenue)} • ${opportunity.probability}%',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: l10n.edit,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddOpportunityScreen(opportunity: opportunity)),
                );
                if (result is Opportunity) {
                  _loadOpportunities();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: l10n.delete,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.delete + ' ' + l10n.opportunityDetails),
                    content: Text(l10n.areYouSureSignOut),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final crmService = CrmService();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    final success = await crmService.deleteOpportunity(opportunity.id);
                    Navigator.of(context).pop(); // Remove loading dialog
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
                      );
                      _loadOpportunities();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.failed), backgroundColor: Colors.red),
                      );
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.failed), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpportunityDetailScreen(opportunity: opportunity)),
          );
          if (result is Opportunity) {
            _loadOpportunities();
          }
        },
        isThreeLine: true,
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