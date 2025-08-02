import 'odoo_service.dart';

class OrderService {
  Future<int> createOrderLine(int orderId, Map<String, dynamic> values) async {
    final lineVals = Map<String, dynamic>.from(values);
    lineVals['order_id'] = orderId;
    return await _odoo.create('sale.order.line', lineVals);
  }

  Future<bool> updateOrderLine(int lineId, Map<String, dynamic> values) async {
    return await _odoo.write('sale.order.line', [lineId], values);
  }
  static const String _model = 'sale.order';
  final OdooService _odoo = OdooService();

  /// Fetches order details and order lines for the details screen
  Future<Map<String, dynamic>?> getOrderDetails(int id) async {
    final order = await getOrder(id, fields: [
      'id', 'name', 'partner_id', 'date_order', 'amount_total', 'state', 'user_id', 'order_line',
      'company_id', 'invoice_status', 'activity_ids', 'payment_term_id', 'sale_order_template_id',
      'amount_untaxed', 'amount_tax'
    ]);
    if (order == null) return null;

    // Fetch order lines
    final orderLineIds = List<int>.from(order['order_line'] ?? []);
    final orderLines = orderLineIds.isNotEmpty
        ? await _odoo.read('sale.order.line', orderLineIds, [
            'id', 'product_id', 'name', 'product_uom_qty', 'qty_delivered', 'qty_invoiced',
            'price_unit', 'tax_id', 'price_subtotal', 'price_total'
          ])
        : [];

    order['order_lines'] = orderLines;
    return order;
  }

  Future<List<Map<String, dynamic>>> fetchOrders({
    int offset = 0,
    int? limit,
    String order = 'id desc',
    List<String>? fields,
  }) async {
    final List<String> defaultFields = [
      'id', 'name', 'partner_id', 'date_order', 'amount_total', 'state', 'user_id', 'order_line', 'active', 'activity_ids', 'company_id', 'invoice_status'
    ];
    // Fetch all orders (no domain filter)
    try {
      final result = await _odoo.searchRead(
        _model,
        [],
        fields ?? defaultFields,
        offset: offset,
        limit: limit,
        order: order,
      );
      // Defensive: filter out any non-map records
      return (result as List).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      // If result is not a list or any error occurs, return empty list
      return [];
    }
  }

  Future<Map<String, dynamic>?> getOrder(int id, {List<String>? fields}) async {
    final orders = await _odoo.read(_model, [id], fields ?? [
      'id', 'name', 'partner_id', 'date_order', 'amount_total', 'state', 'user_id', 'order_line', 'active'
    ]);
    return orders.isNotEmpty ? orders.first : null;
  }

  Future<int> createOrder(Map<String, dynamic> values) async {
    return await _odoo.create(_model, values);
  }

  Future<bool> updateOrder(int id, Map<String, dynamic> values) async {
    return await _odoo.write(_model, [id], values);
  }

  Future<bool> deleteOrder(int id) async {
    return await _odoo.unlink(_model, [id]);
  }
}
