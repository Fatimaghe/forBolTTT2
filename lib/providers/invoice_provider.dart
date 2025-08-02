import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/odoo_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final OdooService _odooService = OdooService();
  List<Invoice> _invoices = [];
  bool _loading = false;
  String? _error;

  List<Invoice> get invoices => _invoices;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchInvoices() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Only fetch customer invoices (move_type = 'out_invoice')
      final data = await _odooService.searchRead(
        'account.move',
        [
          ['move_type', '=', 'out_invoice']
        ],
        [
          'id', 'name', 'partner_id', 'invoice_date', 'invoice_date_due', 'state',
          'amount_untaxed', 'amount_tax', 'amount_total', 'invoice_payment_term_id',
          'ref', 'invoice_line_ids', 'create_date', 'write_date', 'move_type'
        ],
      );
      print('Odoo raw invoice data:');
      print(data);
      List<Invoice> allInvoices = data.map((json) => Invoice.fromJson(json)).toList();
      // Deduplicate by invoice number (name), keep latest write_date
      final Map<String, Invoice> deduped = {};
      for (final inv in allInvoices) {
        if (!deduped.containsKey(inv.number)) {
          deduped[inv.number] = inv;
        } else {
          // Compare write_date, keep the latest
          final existing = deduped[inv.number]!;
          if (inv.updatedAt.isAfter(existing.updatedAt)) {
            deduped[inv.number] = inv;
          }
        }
      }
      _invoices = deduped.values.toList();
      print('Parsed invoice count (deduped): ${_invoices.length}');
    } catch (e) {
      if (e is OdooException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      print('Error fetching invoices: $_error');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> addInvoice(Invoice invoice) async {
    try {
      await _odooService.create('account.move', invoice.toJson());
      await fetchInvoices();
      return true;
    } catch (e) {
      if (e is OdooException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInvoice(Invoice invoice) async {
    try {
      await _odooService.write('account.move', [int.parse(invoice.id)], invoice.toJson());
      await fetchInvoices();
      return true;
    } catch (e) {
      if (e is OdooException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      await _odooService.unlink('account.move', [int.parse(id)]);
      await fetchInvoices();
      return true;
    } catch (e) {
      if (e is OdooException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    }
  }
}
