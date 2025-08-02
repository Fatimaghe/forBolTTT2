class Invoice {
  final String id;
  final String number;
  final String customerId;
  final String customerName;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status; // draft, posted, paid, cancelled
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String paymentTerms;
  final String reference;
  final List<InvoiceLine> lines;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    required this.invoiceDate,
    required this.dueDate,
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

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Odoo field mapping with robust handling for false/null values
    String safeString(dynamic value) => (value == null || value == false) ? '' : value.toString();
    DateTime safeDate(dynamic value) {
      if (value == null || value == false || value == '') return DateTime.now();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }
    List safeList(dynamic value) => (value is List) ? value : [];

    return Invoice(
      id: safeString(json['id']),
      number: safeString(json['name']),
      customerId: (json['partner_id'] is List && json['partner_id'].isNotEmpty)
          ? safeString(json['partner_id'][0])
          : '',
      customerName: (json['partner_id'] is List && json['partner_id'].length > 1)
          ? safeString(json['partner_id'][1])
          : '',
      invoiceDate: safeDate(json['invoice_date']),
      dueDate: safeDate(json['invoice_date_due']),
      status: safeString(json['state']),
      subtotal: (json['amount_untaxed'] is num) ? json['amount_untaxed'].toDouble() : 0.0,
      taxAmount: (json['amount_tax'] is num) ? json['amount_tax'].toDouble() : 0.0,
      totalAmount: (json['amount_total'] is num) ? json['amount_total'].toDouble() : 0.0,
      paymentTerms: (json['invoice_payment_term_id'] is List && json['invoice_payment_term_id'].length > 1)
          ? safeString(json['invoice_payment_term_id'][1])
          : '',
      reference: safeString(json['ref']),
      lines: const [], // Not expanded here; needs separate fetch if required
      createdAt: safeDate(json['create_date']),
      updatedAt: safeDate(json['write_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'customer_id': customerId,
      'customer_name': customerName,
      'invoice_date': invoiceDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
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

class InvoiceLine {
  final String id;
  final String productId;
  final String productName;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final double subtotal;

  InvoiceLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.taxRate,
    required this.subtotal,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    return InvoiceLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unitPrice: json['unit_price'].toDouble(),
      discount: json['discount'].toDouble(),
      taxRate: json['tax_rate'].toDouble(),
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
      'tax_rate': taxRate,
      'subtotal': subtotal,
    };
  }
}