import '../models/customer.dart';
import '../models/opportunity.dart';
import 'odoo_service.dart';


class CrmService {
  // Fetch all CRM stages
  Future<List<Map<String, dynamic>>> getOpportunityStages() async {
    try {
      final fields = ['id', 'name', 'sequence', 'probability', 'fold'];
      final records = await _odooService.searchRead(
        'crm.stage',
        [],
        fields,
        order: 'sequence asc',
      );
      return List<Map<String, dynamic>>.from(records);
    } catch (e) {
      throw Exception('Failed to fetch stages: \\${e.toString()}');
    }
  }
  /// Deletes a customer by their Odoo ID (as string or int-convertible).
  /// Returns true if the customer was deleted successfully.
  Future<bool> deleteCustomerById(String customerId) async {
    try {
      final id = int.parse(customerId);
      return await _odooService.unlink('res.partner', [id]);
    } catch (e) {
      throw Exception('Failed to delete customer: \\${e.toString()}');
    }
  }
  static final CrmService _instance = CrmService._internal();
  factory CrmService() => _instance;
  CrmService._internal();

  final OdooService _odooService = OdooService();

  // Customer/Partner related methods
  Future<List<Customer>> getCustomers({

    int offset = 0,
    int limit = 80,
    String? searchTerm,
    String customerType = 'company', // 'company', 'individual', or 'all'
    String? parentId, // New: filter by parent company
  }) async {
    try {
      List<dynamic> domain = [];
      if (customerType == 'company') {
        domain.add(['is_company', '=', true]);
      } else if (customerType == 'individual') {
        domain.add(['is_company', '=', false]);
      } // 'all' means no filter
      if (searchTerm != null && searchTerm.isNotEmpty) {
        domain.add(['name', 'ilike', searchTerm]);
      }
      if (parentId != null && parentId.isNotEmpty) {
        domain.add(['parent_id', '=', int.tryParse(parentId) ?? parentId]);
      }
      final fields = [
        'id', 'name', 'email', 'phone', 'mobile', 'street', 'street2',
        'city', 'state_id', 'country_id', 'zip', 'website', 'industry_id',
        'customer_rank', 'supplier_rank', 'is_company', 'create_date',
        'parent_id'
      ];
      final records = await _odooService.searchRead(
        'res.partner',
        domain,
        fields,
        offset: offset,
        limit: limit,
        order: 'name asc', // Always fetch in alphabetical order
      );
      final customerList = records.map((record) => _mapToCustomer(record)).toList();
      customerList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return customerList;
    } catch (e) {
      throw Exception('Failed to fetch customers: ${e.toString()}');
    }
  }

  Future<Customer?> getCustomerById(int id) async {
    try {
      final fields = [
        'id', 'name', 'email', 'phone', 'mobile', 'street', 'street2',
        'city', 'state_id', 'country_id', 'zip', 'website', 'industry_id',
        'customer_rank', 'supplier_rank', 'is_company', 'create_date'
      ];

      final records = await _odooService.read('res.partner', [id], fields);
      if (records.isNotEmpty) {
        return _mapToCustomer(records.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch customer: ${e.toString()}');
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      final values = _mapFromCustomer(customer);
      final id = await _odooService.create('res.partner', values);

      final createdCustomer = await getCustomerById(id);
      return createdCustomer!;
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final values = _mapFromCustomer(customer);
      final id = int.tryParse(customer.id);
      if (id == null) {
        throw Exception('Cannot update: Customer does not exist on server.');
      }
      await _odooService.write('res.partner', [id], values);
      final updatedCustomer = await getCustomerById(id);
      return updatedCustomer!;
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      final id = int.parse(customerId);
      return await _odooService.unlink('res.partner', [id]);
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  // Opportunity related methods
  Future<List<Opportunity>> getOpportunities({
    int offset = 0,
    int limit = 80,
    String? searchTerm,
  }) async {
    try {
      List<dynamic> domain = [];

      if (searchTerm != null && searchTerm.isNotEmpty) {
        domain.add(['name', 'ilike', searchTerm]);
      }

      final fields = [
        'id', 'name', 'partner_id', 'expected_revenue', 'probability',
        'stage_id', 'date_deadline', 'user_id', 'description',
        'create_date', 'write_date', 'tag_ids',
        'campaign_id', 'medium_id', 'source_id', 'referred',
        /*'job_position',*/ 'mobile', 'company_id', 'team_id',
        /*'days_to_assign', 'days_to_close',*/ 'email_from', 'phone',
        'priority', 'type', 'function', 'city', 'state_id', 'country_id',
        'zip', 'website'
      ];

      final records = await _odooService.searchRead(
        'crm.lead',
        domain,
        fields,
        offset: offset,
        limit: limit,
        order: 'create_date desc',
      );

      return records.map((record) => _mapToOpportunity(record)).toList();
    } catch (e) {
      throw Exception('Failed to fetch opportunities: ${e.toString()}');
    }
  }

  Future<Opportunity?> getOpportunityById(int id) async {
    try {
      final fields = [
        'id', 'name', 'partner_id', 'expected_revenue', 'probability',
        'stage_id', 'date_deadline', 'user_id', 'description',
        'create_date', 'write_date', 'tag_ids',
        'campaign_id', 'medium_id', 'source_id', 'referred',
        /*'job_position',*/ 'mobile', 'company_id', 'team_id',
        /*'days_to_assign', 'days_to_close',*/ 'email_from', 'phone',
        'priority', 'type', 'function', 'city', 'state_id', 'country_id',
        'zip', 'website'
      ];

      final records = await _odooService.read('crm.lead', [id], fields);
      if (records.isNotEmpty) {
        return _mapToOpportunity(records.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch opportunity: ${e.toString()}');
    }
  }

  Future<Opportunity> createOpportunity(Opportunity opportunity) async {
    try {
      final values = _mapFromOpportunity(opportunity);
      final id = await _odooService.create('crm.lead', values);

      final createdOpportunity = await getOpportunityById(id);
      return createdOpportunity!;
    } catch (e) {
      throw Exception('Failed to create opportunity: ${e.toString()}');
    }
  }

  Future<Opportunity> updateOpportunity(Opportunity opportunity) async {
    try {
      final values = _mapFromOpportunity(opportunity);
      final id = int.parse(opportunity.id);

      await _odooService.write('crm.lead', [id], values);

      final updatedOpportunity = await getOpportunityById(id);
      return updatedOpportunity!;
    } catch (e) {
      throw Exception('Failed to update opportunity: ${e.toString()}');
    }
  }

  Future<bool> deleteOpportunity(String opportunityId) async {
    try {
      final id = int.parse(opportunityId);
      return await _odooService.unlink('crm.lead', [id]);
    } catch (e) {
      throw Exception('Failed to delete opportunity: ${e.toString()}');
    }
  }

  // Helper methods to map between Odoo records and app models
  Customer _mapToCustomer(Map<String, dynamic> record) {
    String parseString(dynamic value) => value is String ? value : (value == null ? '' : value.toString());
    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime(1970);
      }
      return DateTime(1970);
    }
    return Customer(
      id: record['id'] != null ? record['id'].toString() : '',
      name: parseString(record['name']),
      email: parseString(record['email']),
      phone: parseString(record['phone'] ?? record['mobile']),
      address: parseString(_buildAddress(record)),
      city: parseString(record['city']),
      state: record['state_id'] is List && record['state_id'].length > 1 ? parseString(record['state_id'][1]) : '',
      country: record['country_id'] is List && record['country_id'].length > 1 ? parseString(record['country_id'][1]) : '',
      zipCode: parseString(record['zip']),
      website: parseString(record['website']),
      industry: record['industry_id'] is List && record['industry_id'].length > 1 ? parseString(record['industry_id'][1]) : '',
      customerType: record['is_company'] == true ? 'company' : 'individual',
      isActive: true,
      status: 'active',
      createdAt: record['create_date'] != null ? parseDate(record['create_date']) : DateTime.now(),
      parentId: record['parent_id'] is List && record['parent_id'].isNotEmpty ? parseString(record['parent_id'][0]) : null,
      parentName: record['parent_id'] is List && record['parent_id'].length > 1 ? parseString(record['parent_id'][1]) : null,
    );
  }

  Map<String, dynamic> _mapFromCustomer(Customer customer) {
    return {
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'street': customer.address,
      'city': customer.city,
      'zip': customer.zipCode,
      'website': customer.website,
      'is_company': customer.customerType == 'company',
      'customer_rank': 1,
    };
  }

  Opportunity _mapToOpportunity(Map<String, dynamic> record) {
    // Extract tags as list of names if present (Odoo often returns as list of [id, name] pairs)
    List<String> tags = [];
    if (record['tag_ids'] is List) {
      tags = (record['tag_ids'] as List)
          .where((t) => t is List && t.length > 1)
          .map<String>((t) => t[1].toString())
          .toList();
    } else if (record['tags'] is List) {
      tags = List<String>.from(record['tags'].map((t) => t.toString()));
    }

    // Fetch extra details from related customer/partner if available
    String customerName = _getRelationName(record['partner_id']);
    String customerId = _getRelationId(record['partner_id']);
    Map<String, dynamic>? partner = record['partner_id'] is List && record['partner_id'].length > 1 && record['partner_id'][1] is Map<String, dynamic>
      ? record['partner_id'][1] as Map<String, dynamic>
      : null;

    // Fallbacks if partner is not embedded (most likely not, so will be empty)
    String companyName = partner?['name'] ?? customerName;
    String address = partner != null ? (partner['street'] ?? '') : '';
    String city = partner != null ? (partner['city'] ?? '') : '';
    String stateName = partner != null && partner['state_id'] is List && partner['state_id'].length > 1 ? partner['state_id'][1] : '';
    String country = partner != null && partner['country_id'] is List && partner['country_id'].length > 1 ? partner['country_id'][1] : '';
    String zipCode = partner?['zip'] ?? '';
    String website = partner?['website'] ?? '';
    String jobPosition = partner?['function'] ?? '';
    String mobile = partner?['mobile'] ?? '';
    String industry = partner != null && partner['industry_id'] is List && partner['industry_id'].length > 1 ? partner['industry_id'][1] : '';

    return Opportunity(
      id: record['id'] != null ? record['id'].toString() : '',
      title: record['name'] is String ? record['name'] : '',
      customerId: customerId,
      customerName: customerName,
      expectedRevenue: (record['expected_revenue'] is num)
          ? (record['expected_revenue'] as num).toDouble()
          : double.tryParse(record['expected_revenue']?.toString() ?? '') ?? 0.0,
      probability: (record['probability'] is num)
          ? (record['probability'] as num).round()
          : int.tryParse(record['probability']?.toString() ?? '') ?? 0,
      stage: _getRelationName(record['stage_id']),
      state: 'open',
      expectedCloseDate: _parseDate(record['date_deadline']) ?? DateTime.now().add(const Duration(days: 30)),
      salesPerson: _getRelationName(record['user_id']),
      description: record['description'] is String ? record['description'] : '',
      createdAt: _parseDate(record['create_date']) ?? DateTime.now(),
      tags: tags,
      campaign: _getRelationName(record['campaign_id']),
      medium: _getRelationName(record['medium_id']),
      source: _getRelationName(record['source_id']),
      referredBy: record['referred']?.toString() ?? '',
      jobPosition: jobPosition,
      mobile: mobile,
      company: companyName,
      salesTeam: _getRelationName(record['team_id']),
      daysToAssign: 0, // Not available, placeholder
      daysToClose: 0, // Not available, placeholder
      email: record['email_from']?.toString() ?? (partner?['email'] ?? ''),
      phone: record['phone']?.toString() ?? (partner?['phone'] ?? ''),
      priority: record['priority']?.toString() ?? '',
      type: record['type']?.toString() ?? '',
      function: partner?['function'] ?? '',
      city: city,
      stateName: stateName,
      country: country,
      zipCode: zipCode,
      website: website,
      industry: industry,
    );
  }

  Map<String, dynamic> _mapFromOpportunity(Opportunity opportunity) {
    return {
      'name': opportunity.title,
      'partner_id': int.tryParse(opportunity.customerId),
      'expected_revenue': opportunity.expectedRevenue,
      'probability': opportunity.probability,
      'date_deadline': opportunity.expectedCloseDate.toIso8601String(),
      'description': opportunity.description,
    };
  }

  String _buildAddress(Map<String, dynamic> record) {
    final parts = <String>[];
    if (record['street'] != null && record['street'].toString().isNotEmpty) {
      parts.add(record['street'].toString());
    }
    if (record['street2'] != null && record['street2'].toString().isNotEmpty) {
      parts.add(record['street2'].toString());
    }
    return parts.join(', ');
  }

  String _getRelationName(dynamic relation) {
    if (relation == null || relation is bool) return '';
    if (relation is List && relation.length >= 2) {
      return relation[1]?.toString() ?? '';
    }
    return relation.toString();
  }

  String _getRelationId(dynamic relation) {
    if (relation == null || relation is bool) return '';
    if (relation is List && relation.isNotEmpty) {
      return relation[0].toString();
    }
    return relation.toString();
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr == false) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }
}