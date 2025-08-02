class InventoryItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final String locationId;
  final String locationName;
  final double quantityOnHand;
  final double quantityReserved;
  final double quantityAvailable;
  final double unitCost;
  final double totalValue;
  final String categId;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.locationId,
    required this.locationName,
    required this.quantityOnHand,
    required this.quantityReserved,
    required this.quantityAvailable,
    required this.unitCost,
    required this.totalValue,
    required this.categId,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      sku: json['sku'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      quantityOnHand: json['quantity_on_hand'].toDouble(),
      quantityReserved: json['quantity_reserved'].toDouble(),
      quantityAvailable: json['quantity_available'].toDouble(),
      unitCost: json['unit_cost'].toDouble(),
      totalValue: json['total_value'].toDouble(),
      categId: json['categ_id']?.toString() ?? '',
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'location_id': locationId,
      'location_name': locationName,
      'quantity_on_hand': quantityOnHand,
      'quantity_reserved': quantityReserved,
      'quantity_available': quantityAvailable,
      'unit_cost': unitCost,
      'total_value': totalValue,
      'categ_id': categId,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}