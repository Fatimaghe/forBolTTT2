import 'odoo_service.dart';

class DropdownService {
  final OdooService _odoo = OdooService();

  Future<List<Map<String, dynamic>>> getPartners() async {
    return await _odoo.searchRead('res.partner', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getPaymentTerms() async {
    return await _odoo.searchRead('account.payment.term', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getQuotationTemplates() async {
    return await _odoo.searchRead('sale.order.template', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _odoo.searchRead('res.users', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getSalesTeams() async {
    return await _odoo.searchRead('crm.team', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    return await _odoo.searchRead('res.company', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _odoo.searchRead('product.product', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getUoMs() async {
    return await _odoo.searchRead('uom.uom', [], ['id', 'name']);
  }

  Future<List<Map<String, dynamic>>> getTaxes() async {
    return await _odoo.searchRead('account.tax', [], ['id', 'name']);
  }
}
