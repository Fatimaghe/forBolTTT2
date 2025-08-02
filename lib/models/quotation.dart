class Quotation {
  final String id;
  final String number;
  final String customerId;
  final String customerName;
  final DateTime quotationDate;
  final DateTime validUntil;
  final String status;
  final String salesPerson;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String paymentTerms;
  final String reference;
  final List<QuotationLine> lines;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quotation({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    required this.quotationDate,
    required this.validUntil,
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

  bool get isExpired => DateTime.now().isAfter(validUntil);

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'],
      number: json['number'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      quotationDate: DateTime.parse(json['quotation_date']),
      validUntil: DateTime.parse(json['valid_until']),
      status: json['status'],
      salesPerson: json['sales_person'],
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['tax_amount'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      paymentTerms: json['payment_terms'],
      reference: json['reference'],
      lines: (json['lines'] as List).map((line) => QuotationLine.fromJson(line)).toList(),
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
      'quotation_date': quotationDate.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
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

  Quotation copyWith({
    String? id,
    String? number,
    String? customerId,
    String? customerName,
    DateTime? quotationDate,
    DateTime? validUntil,
    String? status,
    String? salesPerson,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? paymentTerms,
    String? reference,
    List<QuotationLine>? lines,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quotation(
      id: id ?? this.id,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      quotationDate: quotationDate ?? this.quotationDate,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      salesPerson: salesPerson ?? this.salesPerson,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      reference: reference ?? this.reference,
      lines: lines ?? this.lines,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class QuotationLine {
  final String id;
  final String productId;
  final String productName;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double subtotal;

  QuotationLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.subtotal,
  });

  factory QuotationLine.fromJson(Map<String, dynamic> json) {
    return QuotationLine(
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