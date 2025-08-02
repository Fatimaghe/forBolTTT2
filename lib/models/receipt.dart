class Receipt {
  final String id;
  final String number;
  final String supplierId;
  final String supplierName;
  final String purchaseOrderId;
  final DateTime receiptDate;
  final String status; // draft, done, cancelled
  final String locationId;
  final String locationName;
  final List<ReceiptLine> lines;
  final String notes;
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.number,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseOrderId,
    required this.receiptDate,
    required this.status,
    required this.locationId,
    required this.locationName,
    required this.lines,
    required this.notes,
    required this.createdAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      number: json['number'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      purchaseOrderId: json['purchase_order_id'],
      receiptDate: DateTime.parse(json['receipt_date']),
      status: json['status'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      lines: (json['lines'] as List).map((line) => ReceiptLine.fromJson(line)).toList(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'purchase_order_id': purchaseOrderId,
      'receipt_date': receiptDate.toIso8601String(),
      'status': status,
      'location_id': locationId,
      'location_name': locationName,
      'lines': lines.map((line) => line.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ReceiptLine {
  final String id;
  final String productId;
  final String productName;
  final double quantityOrdered;
  final double quantityReceived;
  final double unitCost;
  final String lotNumber;

  ReceiptLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    required this.lotNumber,
  });

  factory ReceiptLine.fromJson(Map<String, dynamic> json) {
    return ReceiptLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantityOrdered: json['quantity_ordered'].toDouble(),
      quantityReceived: json['quantity_received'].toDouble(),
      unitCost: json['unit_cost'].toDouble(),
      lotNumber: json['lot_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_ordered': quantityOrdered,
      'quantity_received': quantityReceived,
      'unit_cost': unitCost,
      'lot_number': lotNumber,
    };
  }
}