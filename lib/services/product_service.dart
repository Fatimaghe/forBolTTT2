import 'odoo_service.dart';

class ProductService {
  static const String _model = 'product.product';
  final OdooService _odoo = OdooService();

  Future<List<Map<String, dynamic>>> fetchProducts({
    int offset = 0,
    int? limit,
    String order = 'id desc',
    List<String>? fields,
  }) async {
    final List<String> defaultFields = [
      'id',
      'name',
      'default_code',
      'list_price',
      'standard_price',
      'qty_available',
      'uom_id',
      'categ_id',
      'active',
      'image_128',
      'virtual_available',
      'incoming_qty',
      'outgoing_qty',
      'taxes_id',
      'invoice_policy',
      // add any other needed fields here
    ];
    final result = await _odoo.searchRead(
      _model,
      [['active', '=', true]],
      fields ?? defaultFields,
      offset: offset,
      limit: limit,
      order: order,
    );
    
    return result;
  }

  Future<Map<String, dynamic>?> getProduct(int id, {List<String>? fields}) async {
    final products = await _odoo.read(_model, [id], fields ?? [
      'id', 'name', 'default_code', 'list_price', 'standard_price', 'qty_available', 'uom_id', 'categ_id', 'active'
    ]);
    return products.isNotEmpty ? products.first : null;
  }

  Future<int> createProduct(Map<String, dynamic> values) async {
    return await _odoo.create(_model, values);
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> values) async {
    return await _odoo.write(_model, [id], values);
  }

  Future<bool> deleteProduct(int id) async {
    return await _odoo.unlink(_model, [id]);
  }
}
