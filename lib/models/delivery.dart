class Delivery {
  final String id;
  final String number;
  final String customerId;
  final String customerName;
  final String salesOrderId;
  final DateTime deliveryDate;
  final String status; // draft, ready, done, cancelled
  final String sourceLocationId;
  final String sourceLocationName;
  final String destinationAddress;
  final List<DeliveryLine> lines;
  final String trackingNumber;
  final String carrier;
  final String notes;
  final DateTime createdAt;

  Delivery({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    required this.salesOrderId,
    required this.deliveryDate,
    required this.status,
    required this.sourceLocationId,
    required this.sourceLocationName,
    required this.destinationAddress,
    required this.lines,
    required this.trackingNumber,
    required this.carrier,
    required this.notes,
    required this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      number: json['number'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      salesOrderId: json['sales_order_id'],
      deliveryDate: DateTime.parse(json['delivery_date']),
      status: json['status'],
      sourceLocationId: json['source_location_id'],
      sourceLocationName: json['source_location_name'],
      destinationAddress: json['destination_address'],
      lines: (json['lines'] as List).map((line) => DeliveryLine.fromJson(line)).toList(),
      trackingNumber: json['tracking_number'] ?? '',
      carrier: json['carrier'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'customer_id': customerId,
      'customer_name': customerName,
      'sales_order_id': salesOrderId,
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
      'source_location_id': sourceLocationId,
      'source_location_name': sourceLocationName,
      'destination_address': destinationAddress,
      'lines': lines.map((line) => line.toJson()).toList(),
      'tracking_number': trackingNumber,
      'carrier': carrier,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DeliveryLine {
  final String id;
  final String productId;
  final String productName;
  final double quantityOrdered;
  final double quantityDelivered;
  final String serialNumbers;

  DeliveryLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityOrdered,
    required this.quantityDelivered,
    required this.serialNumbers,
  });

  factory DeliveryLine.fromJson(Map<String, dynamic> json) {
    return DeliveryLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantityOrdered: json['quantity_ordered'].toDouble(),
      quantityDelivered: json['quantity_delivered'].toDouble(),
      serialNumbers: json['serial_numbers'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_ordered': quantityOrdered,
      'quantity_delivered': quantityDelivered,
      'serial_numbers': serialNumbers,
    };
  }
}