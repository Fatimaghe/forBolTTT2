class SalesOrder {
  final String id;
  final String number;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String status;
  final String salesPerson;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String paymentTerms;
  final String reference;
  final List<SalesOrderLine> lines;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesOrder({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.salesPerson,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentTerms,
    required this.reference,
    required this.lines,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'],
      number: json['number'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      orderDate: DateTime.parse(json['order_date']),
      deliveryDate: DateTime.parse(json['delivery_date']),
      status: json['status'],
      salesPerson: json['sales_person'],
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['tax_amount'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      paymentTerms: json['payment_terms'],
      reference: json['reference'],
      lines: (json['lines'] as List).map((line) => SalesOrderLine.fromJson(line)).toList(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
      'sales_person': salesPerson,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_terms': paymentTerms,
      'reference': reference,
      'lines': lines.map((line) => line.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SalesOrderLine {
  final String id;
  final String productId;
  final String productName;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double subtotal;

  SalesOrderLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.subtotal,
  });

  factory SalesOrderLine.fromJson(Map<String, dynamic> json) {
    return SalesOrderLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unitPrice: json['unit_price'].toDouble(),
      discount: json['discount'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'subtotal': subtotal,
    };
  }
}