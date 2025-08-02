import '../models/quotation.dart';
import 'odoo_service.dart';

class QuotationService {
  Future<void> cancelQuotation(String quotationId) async {
    try {
      // Odoo expects 'state' to be set to 'cancel' for cancellation
      final values = {'state': 'cancel'};
      await _odooService.write('sale.order', [int.parse(quotationId)], values);
    } catch (e) {
      throw Exception('Failed to cancel quotation: ${e.toString()}');
    }
  }
  Future<void> deleteQuotation(String quotationId) async {
    try {
      print('Attempting to delete quotation with id: $quotationId');
      final result = await _odooService.unlink('sale.order', [int.parse(quotationId)]);
      print('Odoo unlink result: $result');
      if (result != true) {
        print('Odoo did not confirm deletion.');
        throw Exception('Failed to delete quotation: Odoo did not confirm deletion.');
      }
      print('Quotation deleted successfully.');
    } catch (e) {
      print('Exception during deletion: $e');
      throw Exception('Failed to delete quotation: ${e.toString()}');
    }
  }
  Future<void> updateQuotation(Quotation quotation) async {
    try {
      final values = {
        'name': quotation.number,
        'partner_id': int.tryParse(quotation.customerId),
        'user_id': quotation.salesPerson,
        'note': quotation.notes,
        'amount_total': quotation.totalAmount,
      };
      await _odooService.write('sale.order', [int.parse(quotation.id)], values);
    } catch (e) {
      throw Exception('Failed to update quotation: ${e.toString()}');
    }
  }
  static final QuotationService _instance = QuotationService._internal();
  factory QuotationService() => _instance;
  QuotationService._internal();

  final OdooService _odooService = OdooService();

  Future<List<Quotation>> getQuotations({
    int offset = 0,
    int limit = 50,
    String? searchTerm,
  }) async {
    try {
      List<dynamic> domain = [];
      if (searchTerm != null && searchTerm.isNotEmpty) {
        domain.add(['name', 'ilike', searchTerm]);
      }
      final fields = [
        'id', 'name', 'partner_id', 'date_order', 'validity_date', 'state',
        'user_id', 'amount_untaxed', 'amount_tax', 'amount_total',
        'payment_term_id', 'client_order_ref', 'order_line', 'note',
        'create_date', 'write_date'
      ];
      final records = await _odooService.searchRead(
        'sale.order',
        domain,
        fields,
        offset: offset,
        limit: limit,
        order: 'date_order desc',
      );
      List<Quotation> quotations = [];
      for (final record in records) {
        final quotation = await _mapToQuotationAsync(record);
        quotations.add(quotation);
      }
      return quotations;
    } catch (e) {
      throw Exception('Failed to fetch quotations: ${e.toString()}');
    }
  }

  Future<Quotation> _mapToQuotationAsync(Map<String, dynamic> record) async {
    // Removed debug print statements to improve performance and prevent console flooding
    String parseString(dynamic value) => value is String ? value : (value == null ? '' : value.toString());
    double parseDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0.0;
    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime(1970);
      }
      return DateTime(1970);
    }
    List<QuotationLine> lines = [];
    if (record['order_line'] is List && (record['order_line'] as List).isNotEmpty) {
      List<int> lineIds = (record['order_line'] as List)
        .where((id) => id is int || (id is List && id.isNotEmpty))
        .map((id) => id is int ? id : (id is List ? id[0] : null))
        .whereType<int>()
        .toList();
      if (lineIds.isNotEmpty) {
        final lineFields = [
          'id', 'product_id', 'name', 'product_uom_qty', 'price_unit', 'discount', 'price_subtotal'
        ];
        try {
          final lineRecords = await _odooService.read('sale.order.line', lineIds, lineFields);
          lines = (lineRecords as List)
            .whereType<Map<String, dynamic>>()
            .map((line) => QuotationLine(
              id: parseString(line['id']),
              productId: parseString(line['product_id'] is List ? line['product_id'][0] : line['product_id']),
              productName: parseString(line['product_id'] is List && line['product_id'].length > 1 ? line['product_id'][1] : ''),
              description: parseString(line['name']),
              quantity: parseDouble(line['product_uom_qty']),
              unitPrice: parseDouble(line['price_unit']),
              discount: parseDouble(line['discount']),
              subtotal: parseDouble(line['price_subtotal']),
            )).toList();
        } catch (e) {
          print('Error fetching order line details: ' + e.toString());
        }
      }
    }
    return Quotation(
      id: parseString(record['id']),
      number: parseString(record['name']),
      customerId: record['partner_id'] is List ? parseString(record['partner_id'][0]) : '',
      customerName: record['partner_id'] is List && record['partner_id'].length > 1 ? parseString(record['partner_id'][1]) : '',
      quotationDate: parseDate(record['date_order']),
      validUntil: parseDate(record['validity_date']),
      status: parseString(record['state']),
      salesPerson: record['user_id'] is List && record['user_id'].length > 1 ? parseString(record['user_id'][1]) : '',
      subtotal: parseDouble(record['amount_untaxed']),
      taxAmount: parseDouble(record['amount_tax']),
      totalAmount: parseDouble(record['amount_total']),
      paymentTerms: record['payment_term_id'] is List && record['payment_term_id'].length > 1 ? parseString(record['payment_term_id'][1]) : '',
      reference: parseString(record['client_order_ref']),
      lines: lines,
      notes: parseString(record['note']),
      createdAt: parseDate(record['create_date']),
      updatedAt: parseDate(record['write_date']),
    );
  }
}
