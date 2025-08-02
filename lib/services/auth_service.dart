import 'dart:async';
import '../models/user.dart';
import 'odoo_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _userController.add(null);
  }

  User? _currentUser;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  final OdooService _odooService = OdooService();

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Odoo login integration
  Future<bool> login(String email, String password) async {
    try {
      // Use JSON-RPC authentication (matching successful Postman request)
      final result = await _odooService.authenticate(email, password);

      if (result['success'] == true) {
        _currentUser = User(
          id: result['uid'].toString(),
          email: email,
          name: result['user_name'] ?? _extractNameFromEmail(email),
          company: result['company_id'] != null ? result['company_id'][1] : 'ODOOFF Company',
          isActive: true,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        _userController.add(_currentUser);
        return true;
      } else {
        print('Login failed: ${result['error']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Registration (Note: Odoo user registration typically requires admin privileges)
  Future<bool> register(String name, String email, String password, String? company) async {
    try {
      // For now, registration is not implemented as it requires admin privileges in Odoo
      // You would need to create users through the Odoo backend or implement a custom endpoint
      throw Exception('Registration not available. Please contact your administrator.');
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _odooService.logout();
    _currentUser = null;
    _userController.add(null);
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Password reset would need to be implemented through Odoo's password reset mechanism
      // This typically involves sending a reset email through Odoo's built-in functionality
      throw Exception('Password reset not implemented. Please contact your administrator.');
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username.split('.').map((part) =>
    part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : ''
    ).join(' ');
  }

  void dispose() {
    _userController.close();
  }
}