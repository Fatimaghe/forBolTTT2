class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String mobile;
  final String jobTitle;
  final String department;
  final String company;
  final String address;
  final String city;
  final String country;
  final String type;
  final String notes;
  final bool isCustomer;
  final bool isSupplier;
  final List<String> tags;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.jobTitle,
    required this.department,
    required this.company,
    required this.address,
    required this.city,
    required this.country,
    required this.type,
    required this.notes,
    required this.isCustomer,
    required this.isSupplier,
    required this.tags,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      jobTitle: json['job_title'],
      department: json['department'],
      company: json['company'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      type: json['type'],
      notes: json['notes'],
      isCustomer: json['is_customer'],
      isSupplier: json['is_supplier'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'job_title': jobTitle,
      'department': department,
      'company': company,
      'address': address,
      'city': city,
      'country': country,
      'type': type,
      'notes': notes,
      'is_customer': isCustomer,
      'is_supplier': isSupplier,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}