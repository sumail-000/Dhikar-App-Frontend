import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // TODO: adjust to your backend host when deploying
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<_ApiResponse> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (headers != null) defaultHeaders.addAll(headers);

    if (auth) {
      final token = await _getToken();
      if (token != null) {
        defaultHeaders['Authorization'] = 'Bearer $token';
      }
    }

    http.Response resp;
    try {
      switch (method) {
        case 'GET':
          resp = await http.get(url, headers: defaultHeaders);
          break;
        case 'POST':
          resp = await http.post(url, headers: defaultHeaders, body: body);
          break;
        case 'PATCH':
          resp = await http.patch(url, headers: defaultHeaders, body: body);
          break;
        case 'DELETE':
          resp = await http.delete(url, headers: defaultHeaders, body: body);
          break;
        default:
          throw Exception('Unsupported method');
      }
    } catch (e) {
      return _ApiResponse(error: 'Network error. Please check your connection.');
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return _ApiResponse(data: {});
      return _ApiResponse(data: jsonDecode(resp.body));
    } else {
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded.containsKey('message')) {
          return _ApiResponse(error: decoded['message'] as String);
        }
        if (decoded is Map && decoded.containsKey('errors')) {
          // build first validation error message
          final errors = decoded['errors'] as Map<String, dynamic>;
          final firstKey = errors.keys.first;
          final firstError = (errors[firstKey] as List).first.toString();
          return _ApiResponse(error: firstError);
        }
      } catch (_) {}
      return _ApiResponse(error: 'Unexpected error (${resp.statusCode}).');
    }
  }

  Future<_ApiResponse> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _request(
      'POST',
      '/auth/register',
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  Future<_ApiResponse> login({
    required String email,
    required String password,
  }) {
    return _request(
      'POST',
      '/auth/login',
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<_ApiResponse> me() {
    return _request('GET', '/auth/me', auth: true);
  }

  Future<_ApiResponse> logout() {
    return _request('POST', '/auth/logout', auth: true);
  }

  Future<_ApiResponse> forgotPassword({required String email}) {
    return _request(
      'POST',
      '/password/forgot',
      body: jsonEncode({'email': email}),
    );
  }
}

class _ApiResponse {
  final dynamic data;
  final String? error;
  _ApiResponse({this.data, this.error});
  bool get ok => error == null;
}