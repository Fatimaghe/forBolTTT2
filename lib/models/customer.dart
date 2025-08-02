class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String website;
  final String industry;
  final String customerType;
  final bool isActive;
  final String status;
  final DateTime createdAt;
  // For individuals: company association
  final String? parentId;
  final String? parentName;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.website,
    required this.industry,
    required this.customerType,
    required this.isActive,
    required this.status,
    required this.createdAt,
    this.parentId,
    this.parentName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) => value is String ? value : '';
    bool parseBool(dynamic value) => value is bool ? value : (value == true || value == 'true');
    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime(1970);
      }
      return DateTime(1970);
    }
    return Customer(
      id: parseString(json['id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
      address: parseString(json['address']),
      city: parseString(json['city']),
      state: parseString(json['state']),
      country: parseString(json['country']),
      zipCode: parseString(json['zip_code']),
      website: parseString(json['website']),
      industry: parseString(json['industry']),
      customerType: parseString(json['customer_type']),
      isActive: parseBool(json['is_active']),
      status: parseString(json['status']),
      createdAt: parseDate(json['created_at']),
      parentId: json['parent_id'] != null ? json['parent_id'].toString() : null,
      parentName: json['parent_name'] != null ? json['parent_name'].toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'website': website,
      'industry': industry,
      'customer_type': customerType,
      'is_active': isActive,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (parentId != null) 'parent_id': parentId,
      if (parentName != null) 'parent_name': parentName,
    };
  }
}