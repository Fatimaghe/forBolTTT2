class PurchaseOrder {
  final String id;
  final String number;
  final String supplierId;
  final String supplierName;
  final String buyer;
  final DateTime orderDate;
  final DateTime expectedDate;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String paymentTerms;
  final String reference;
  final List<PurchaseOrderLine> lines;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseOrder({
    required this.id,
    required this.number,
    required this.supplierId,
    required this.supplierName,
    required this.buyer,
    required this.orderDate,
    required this.expectedDate,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentTerms,
    required this.reference,
    required this.lines,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      number: json['number'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      buyer: json['buyer'],
      orderDate: DateTime.parse(json['order_date']),
      expectedDate: DateTime.parse(json['expected_date']),
      status: json['status'],
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['tax_amount'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      paymentTerms: json['payment_terms'],
      reference: json['reference'],
      lines: (json['lines'] as List).map((line) => PurchaseOrderLine.fromJson(line)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'buyer': buyer,
      'order_date': orderDate.toIso8601String(),
      'expected_date': expectedDate.toIso8601String(),
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_terms': paymentTerms,
      'reference': reference,
      'lines': lines.map((line) => line.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PurchaseOrderLine {
  final String id;
  final String productId;
  final String productName;
  final String description;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  PurchaseOrderLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unitPrice: json['unit_price'].toDouble(),
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
      'subtotal': subtotal,
    };
  }
}