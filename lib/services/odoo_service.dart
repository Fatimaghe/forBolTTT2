import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OdooService {
  // Fetch customers (partners) for dropdowns (id, name only)
  Future<List<Map<String, dynamic>>> fetchCustomers({String? search}) async {
    final domain = [
      ['customer_rank', '>', 0],
      if (search != null && search.isNotEmpty)
        ['name', 'ilike', search],
    ];
    return await searchRead(
      'res.partner',
      domain,
      ['id', 'name'],
      limit: 30,
      order: 'name asc',
    );
  }

  // Fetch products for dropdowns (id, name only)
  Future<List<Map<String, dynamic>>> fetchProducts({String? search}) async {
    final domain = [
      ['sale_ok', '=', true],
      if (search != null && search.isNotEmpty)
        ['name', 'ilike', search],
    ];
    return await searchRead(
      'product.product',
      domain,
      ['id', 'name'],
      limit: 30,
      order: 'name asc',
    );
  }
  // Helper: Convert customer list to dropdown items
  List<Map<String, dynamic>> customerDropdownItems(List<Map<String, dynamic>> customers) {
    return customers.map((c) => {
      'id': c['id'],
      'name': c['name'] ?? '',
    }).toList();
  }

  // Helper: Convert product list to dropdown items
  List<Map<String, dynamic>> productDropdownItems(List<Map<String, dynamic>> products) {
    return products.map((p) => {
      'id': p['id'],
      'name': p['name'] ?? '',
    }).toList();
  }
  static final OdooService _instance = OdooService._internal();
  factory OdooService() => _instance;
  OdooService._internal();

  static const String baseUrl = 'https://244a322a4a82.ngrok-free.app';
  static const String database = 'ODOOFF';

  String? _sessionId;
  int? _uid;
  String? _userContext;

  // Get session info
  String? get sessionId => _sessionId;
  int? get uid => _uid;
  bool get isAuthenticated => _sessionId != null && _uid != null;

  // CORS-friendly headers (avoid preflight)
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',

    if (_sessionId != null) 'Cookie': 'session_id=$_sessionId',
  };

  // Standard headers for other requests
  Map<String, String> get _standardHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'ODOOFF-Mobile-App/1.0',
    if (_sessionId != null) 'Cookie': 'session_id=$_sessionId',
  };
  Future<Map<String, dynamic>> authenticate(String login, String password) async {
    try {
      final url = Uri.parse('$baseUrl/web/session/authenticate');

      // Use JSON body as required by Odoo
      final body = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'db': database,
          'login': login,
          'password': password,
        },
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      print('Making authentication request to: $url');
      print('Request body: $body');

      final response = await http.post(
        url,
        headers: _standardHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('error')) {
          return {
            'success': false,
            'error': jsonResponse['error']['data']['message'] ??
                jsonResponse['error']['message'] ??
                'Authentication failed'
          };
        }

        final result = jsonResponse['result'];

        if (result != null && result['uid'] != false && result['uid'] != null) {
          _uid = result['uid'];

          // Extract session ID from cookies
          final cookies = response.headers['set-cookie'];
          if (cookies != null) {
            final sessionMatch = RegExp(r'session_id=([^;]+)').firstMatch(cookies);
            if (sessionMatch != null) {
              _sessionId = sessionMatch.group(1);
            }
          }

          _userContext = jsonEncode(result['user_context'] ?? {});

          return {
            'success': true,
            'uid': _uid,
            'session_id': _sessionId,
            'user_context': result['user_context'],
            'user_name': result['name'] ?? result['username'] ?? login.split('@')[0],
            'user_email': result['username'] ?? login,
            'company_id': result['company_id'],
            'partner_id': result['partner_id'],
          };
        } else {
          return {'success': false, 'error': 'Invalid credentials'};
        }
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}'};
      }
    } on SocketException {
      return {'success': false, 'error': 'Cannot connect to Odoo server. Please check if the server is running on $baseUrl'};
    } on http.ClientException {
      return {'success': false, 'error': 'Network error occurred. Please check your connection.'};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/web/session/destroy');

      final body = jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {},
        'id': DateTime.now().millisecondsSinceEpoch,
      });

      await http.post(
        url,
        headers: _authHeaders,
        body: body,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _sessionId = null;
      _uid = null;
      _userContext = null;
    }
  }

  // Generic method to call Odoo models
  Future<dynamic> callOdoo(
      String model,
      String method,
      List<dynamic> args, {
        Map<String, dynamic>? kwargs,
      }) async {
    if (!isAuthenticated) {
      throw OdooException('Not authenticated. Please login first.');
    }

    final url = Uri.parse('$baseUrl/web/dataset/call_kw');

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs ?? {},
      },
      'id': DateTime.now().millisecondsSinceEpoch,
    });

    final response = await http.post(
      url,
      headers: _standardHeaders,
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse.containsKey('error')) {
        throw OdooException(
            jsonResponse['error']['data']['message'] ??
                jsonResponse['error']['message'] ??
                'Unknown error occurred'
        );
      }

      return jsonResponse['result'];
    } else {
      throw OdooException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Search records
  Future<List<int>> search(
      String model,
      List<dynamic> domain, {
        int offset = 0,
        int? limit,
        String order = 'id desc',
      }) async {
    final result = await callOdoo(
      model,
      'search',
      [domain],
      kwargs: {
        'offset': offset,
        if (limit != null) 'limit': limit,
        'order': order,
      },
    );
    return List<int>.from(result);
  }

  // Read records
  Future<List<Map<String, dynamic>>> read(
      String model,
      List<int> ids,
      List<String> fields,
      ) async {
    final result = await callOdoo(
      model,
      'read',
      [ids, fields],
    );
    return List<Map<String, dynamic>>.from(result);
  }

  // Search and read records
  Future<List<Map<String, dynamic>>> searchRead(
      String model,
      List<dynamic> domain,
      List<String> fields, {
        int offset = 0,
        int? limit,
        String order = 'id desc',
      }) async {
    final result = await callOdoo(
      model,
      'search_read',
      [domain],
      kwargs: {
        'fields': fields,
        'offset': offset,
        if (limit != null) 'limit': limit,
        'order': order,
      },
    );
    // Filter out any non-map records (e.g., bools)
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    } else {
      return [];
    }
  }

  // Create record
  Future<int> create(String model, Map<String, dynamic> values) async {
    final filtered = _filterWriteableFields(values, model: model);
    final result = await callOdoo(model, 'create', [filtered]);
    return result as int;
  }

  // Update record
  Future<bool> write(String model, List<int> ids, Map<String, dynamic> values) async {
    print('DEBUG: OdooService.write called: model=$model, ids=$ids, values=$values');
    final filtered = _filterWriteableFields(values, model: model);
    final result = await callOdoo(model, 'write', [ids, filtered]);
    print('DEBUG: OdooService.write result: $result');
    return result as bool;
  }
  // Remove non-writeable fields before sending to Odoo
  Map<String, dynamic> _filterWriteableFields(Map<String, dynamic> values, {String? model}) {
    final filtered = Map<String, dynamic>.from(values);
    // Remove common non-writeable fields
    filtered.remove('number');
    filtered.remove('id');
    filtered.remove('customer_name');
    filtered.remove('product_name');
    // Special: map customer_id to partner_id for account.move
    if ((model == 'account.move' || model == null) && filtered.containsKey('customer_id')) {
      filtered['partner_id'] = filtered['customer_id'];
      filtered.remove('customer_id');
    }
    // Remove any other fields as needed
    return filtered;
  }

  // Delete record
  Future<bool> unlink(String model, List<int> ids) async {
    final result = await callOdoo(model, 'unlink', [ids]);
    return result as bool;
  }

  // Get server info
  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final url = Uri.parse('$baseUrl/web/webclient/version_info');

      final body = jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {},
        'id': DateTime.now().millisecondsSinceEpoch,
      });

      final response = await http.post(
        url,
        headers: _standardHeaders,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['result'];
      } else {
        throw OdooException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw OdooException('Failed to get server info: ${e.toString()}');
    }
  }
}

class OdooException implements Exception {
  final String message;
  OdooException(this.message);

  @override
  String toString() => 'OdooException: $message';
}