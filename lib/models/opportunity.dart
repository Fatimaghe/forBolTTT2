class Opportunity {
  final String id;
  final String title;
  final String customerId;
  final String customerName;
  final double expectedRevenue;
  final int probability;
  final String stage;
  final String state;
  final DateTime expectedCloseDate;
  final String salesPerson;
  final String description;
  final DateTime createdAt;
  final List<String> tags;
  // Extra Odoo fields
  final String campaign;
  final String medium;
  final String source;
  final String referredBy;
  final String jobPosition;
  final String mobile;
  final String company;
  final String salesTeam;
  final int daysToAssign;
  final int daysToClose;
  final String email;
  final String phone;
  final String priority;
  final String type;
  final String function;
  final String city;
  final String stateName;
  final String country;
  final String zipCode;
  final String website;
  final String industry;

  Opportunity({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.expectedRevenue,
    required this.probability,
    required this.stage,
    required this.state,
    required this.expectedCloseDate,
    required this.salesPerson,
    required this.description,
    required this.createdAt,
    required this.tags,
    required this.campaign,
    required this.medium,
    required this.source,
    required this.referredBy,
    required this.jobPosition,
    required this.mobile,
    required this.company,
    required this.salesTeam,
    required this.daysToAssign,
    required this.daysToClose,
    required this.email,
    required this.phone,
    required this.priority,
    required this.type,
    required this.function,
    required this.city,
    required this.stateName,
    required this.country,
    required this.zipCode,
    required this.website,
    required this.industry,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is bool) return value ? 'true' : 'false';
      return value.toString();
    }
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }
    return Opportunity(
      id: parseString(json['id'] ?? json['opportunity_id'] ?? json['opportunityId']),
      title: parseString(json['title'] ?? json['name']),
      customerId: parseString(json['customerId'] ?? json['partner_id']),
      customerName: parseString(json['customerName'] ?? json['partner_name']),
      expectedRevenue: parseDouble(json['expectedRevenue'] ?? json['expected_revenue']),
      probability: parseInt(json['probability']),
      stage: parseString(json['stage']),
      state: parseString(json['state'] ?? json['state_id'] ?? json['status']),
      expectedCloseDate: parseDate(json['expectedCloseDate'] ?? json['date_deadline']),
      salesPerson: parseString(json['salesPerson'] ?? json['user_id']),
      description: parseString(json['description']),
      createdAt: parseDate(json['createdAt'] ?? json['create_date']),
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'].map((t) => t is List && t.length > 1 ? t[1].toString() : t.toString()))
          : <String>[],
      campaign: parseString(json['campaign'] ?? json['campaign_id']),
      medium: parseString(json['medium'] ?? json['medium_id']),
      source: parseString(json['source'] ?? json['source_id']),
      referredBy: parseString(json['referredBy'] ?? json['referred']),
      jobPosition: parseString(json['jobPosition'] ?? json['job_position']),
      mobile: parseString(json['mobile']),
      company: parseString(json['company'] ?? json['company_id']),
      salesTeam: parseString(json['salesTeam'] ?? json['team_id']),
      daysToAssign: parseInt(json['daysToAssign'] ?? json['days_to_assign']),
      daysToClose: parseInt(json['daysToClose'] ?? json['days_to_close']),
      email: parseString(json['email'] ?? json['email_from']),
      phone: parseString(json['phone']),
      priority: parseString(json['priority']),
      type: parseString(json['type']),
      function: parseString(json['function']),
      city: parseString(json['city']),
      stateName: parseString(json['stateName'] ?? json['state_id']),
      country: parseString(json['country']),
      zipCode: parseString(json['zipCode'] ?? json['zip']),
      website: parseString(json['website']),
      industry: parseString(json['industry'] ?? json['industry_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customerId': customerId,
      'customerName': customerName,
      'expectedRevenue': expectedRevenue,
      'probability': probability,
      'stage': stage,
      'state': state,
      'expectedCloseDate': expectedCloseDate.toIso8601String(),
      'salesPerson': salesPerson,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}