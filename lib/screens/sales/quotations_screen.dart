import 'package:flutter/material.dart';
import '../../models/quotation.dart';
import '../../services/quotation_service.dart';
import 'quotation_detail_screen.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  List<Quotation> quotations = [];
  List<Quotation> filteredQuotations = [];
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuotations();
  }

  Future<void> _fetchQuotations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      quotations = [];
      filteredQuotations = [];
    });
    int offset = 0;
    const int batchSize = 5;
    bool hasMore = true;
    try {
      while (hasMore) {
        final batch = await QuotationService().getQuotations(offset: offset, limit: batchSize);
        if (batch.isEmpty) {
          hasMore = false;
        } else {
          setState(() {
            quotations.addAll(batch);
            filteredQuotations = quotations;
          });
          offset += batchSize;
          // Optionally, break after first batch for demo purposes
          // Remove this line to load all batches
          // break;
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterQuotations(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredQuotations = quotations;
      } else {
        filteredQuotations = quotations
            .where((quotation) =>
                quotation.number.toLowerCase().contains(query.toLowerCase()) ||
                quotation.customerName.toLowerCase().contains(query.toLowerCase()) ||
                quotation.salesPerson.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.quotationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQuotations,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add quotation screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterQuotations,
              decoration: InputDecoration(
                hintText: localizations.quotationsSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: filteredQuotations.isEmpty
                  ? Center(child: Text(localizations.quotationsNoResults))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredQuotations.length,
                      itemBuilder: (context, index) {
                        final quotation = filteredQuotations[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuotationDetailScreen(quotation: quotation),
                                ),
                              );
                              if (result != null && result is Map) {
                                final deletedId = result['deletedId'];
                                final error = result['error'];
                                await _fetchQuotations();
                                if (context.mounted) {
                                  if (deletedId != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(localizations.quotationsDeletedSuccess),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } else if (result != null && result is Quotation) {
                                await _fetchQuotations();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quotation.number,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          quotation.customerName,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(DateFormat('MMM dd, yyyy').format(quotation.quotationDate), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.business, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          quotation.customerName,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(NumberFormat.currency(symbol: ' 24').format(quotation.totalAmount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          quotation.salesPerson,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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

  // _getStatusColor removed (no longer used)
}