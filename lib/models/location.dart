class Location {
  final String id;
  final String name;
  final String type;
  final String address;
  final String completeAddress;
  final String usage;
  final String barcode;
  final bool isActive;
  final bool isScrapLocation;
  final bool isReturnLocation;
  final String parentLocationId;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.completeAddress,
    required this.usage,
    required this.barcode,
    required this.isActive,
    required this.isScrapLocation,
    required this.isReturnLocation,
    required this.parentLocationId,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      completeAddress: json['complete_address'],
      usage: json['usage'],
      barcode: json['barcode'],
      isActive: json['is_active'],
      isScrapLocation: json['is_scrap_location'],
      isReturnLocation: json['is_return_location'],
      parentLocationId: json['parent_location_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'complete_address': completeAddress,
      'usage': usage,
      'barcode': barcode,
      'is_active': isActive,
      'is_scrap_location': isScrapLocation,
      'is_return_location': isReturnLocation,
      'parent_location_id': parentLocationId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}