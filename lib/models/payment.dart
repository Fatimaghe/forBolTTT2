class Payment {
  final String id;
  final String reference;
  final String invoiceId;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String partnerId;
  final String partnerName;
  final double amount;
  final DateTime paymentDate;
  final String paymentType;
  final String paymentMethod;
  final String status;
  final String state;
  final String memo;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.reference,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.partnerId,
    required this.partnerName,
    required this.amount,
    required this.paymentDate,
    required this.paymentType,
    required this.paymentMethod,
    required this.status,
    required this.state,
    required this.memo,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      reference: json['reference'],
      invoiceId: json['invoice_id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      partnerId: json['partner_id'],
      partnerName: json['partner_name'],
      amount: json['amount'].toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentType: json['payment_type'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      state: json['state'],
      memo: json['memo'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'invoice_id': invoiceId,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_type': paymentType,
      'payment_method': paymentMethod,
      'status': status,
      'state': state,
      'memo': memo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}