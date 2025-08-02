class Product {
  final String id;
  final String name;
  final String defaultCode;
  final String description;
  final int? categId;
  final double standardPrice;
  final double listPrice;
  final bool canBeSold;
  final bool canBePurchased;
  final String productType;
  final int? uomId;
  final String uomName;
  final String barcode;
  final double weight;
  final String image;
  final DateTime createdAt;
  final int available;
  final int inStock;
  final int reserved;
  final int forecasted;
  final int inQty;
  final int outQty;
  final int sold;
  final String customerTaxes;
  final String invoicingPolicy;

  Product({
    required this.id,
    required this.name,
    required this.defaultCode,
    required this.description,
    required this.categId,
    required this.standardPrice,
    required this.listPrice,
    required this.canBeSold,
    required this.canBePurchased,
    required this.productType,
    required this.uomId,
    required this.uomName,
    required this.barcode,
    required this.weight,
    required this.image,
    required this.createdAt,
    this.available = 0,
    this.inStock = 0,
    this.reserved = 0,
    this.forecasted = 0,
    this.inQty = 0,
    this.outQty = 0,
    this.sold = 0,
    this.customerTaxes = '',
    this.invoicingPolicy = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    int? categId;
    if (json['categ_id'] is int) {
      categId = json['categ_id'];
    } else if (json['categ_id'] is List && json['categ_id'].isNotEmpty) {
      categId = json['categ_id'][0];
    } else if (json['categ_id'] != null) {
      categId = int.tryParse(json['categ_id'].toString());
    }
    int? uomId;
    String uomName = '';
    if (json['uom_id'] is int) {
      uomId = json['uom_id'];
    } else if (json['uom_id'] is List && json['uom_id'].isNotEmpty) {
      uomId = json['uom_id'][0];
      uomName = json['uom_id'].length > 1 ? json['uom_id'][1].toString() : '';
    } else if (json['uom_id'] != null) {
      uomId = int.tryParse(json['uom_id'].toString());
    }
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      defaultCode: json['default_code'] ?? '',
      description: json['description'] ?? '',
      categId: categId,
      standardPrice: (json['standard_price'] ?? 0).toDouble(),
      listPrice: (json['list_price'] ?? 0).toDouble(),
      canBeSold: json['can_be_sold'] ?? true,
      canBePurchased: json['can_be_purchased'] ?? true,
      productType: json['product_type'] ?? '',
      uomId: uomId,
      uomName: uomName,
      barcode: json['barcode'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      available: json['available'] ?? 0,
      inStock: json['in_stock'] ?? 0,
      reserved: json['reserved'] ?? 0,
      forecasted: json['forecasted'] ?? 0,
      inQty: json['in_qty'] ?? 0,
      outQty: json['out_qty'] ?? 0,
      sold: json['sold'] ?? 0,
      customerTaxes: json['customer_taxes'] ?? '',
      invoicingPolicy: json['invoicing_policy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_code': defaultCode,
      'description': description,
      'categ_id': categId,
      'standard_price': standardPrice,
      'list_price': listPrice,
      'can_be_sold': canBeSold,
      'can_be_purchased': canBePurchased,
      'product_type': productType,
      'uom_id': uomId,
      'barcode': barcode,
      'weight': weight,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'available': available,
      'in_stock': inStock,
      'reserved': reserved,
      'forecasted': forecasted,
      'in_qty': inQty,
      'out_qty': outQty,
      'sold': sold,
      'customer_taxes': customerTaxes,
      'invoicing_policy': invoicingPolicy,
    };
  }
  // ...existing code...
}