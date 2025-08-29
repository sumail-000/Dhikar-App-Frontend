import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // TODO: adjust to your backend host when deploying
  static const String baseUrl = String.fromEnvironment('API_BASE', defaultValue: 'http://192.168.1.5:8000/api');

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

    // Debug logging
    print('=== API Request Debug ===');
    print('URL: $url');
    print('Method: $method');
    print('Headers: $defaultHeaders');
    print('Body: $body');
    print('========================');

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
    required String username,
    required String email,
    required String password,
  }) {
    return _request(
      'POST',
      '/auth/register',
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
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

  Future<_ApiResponse> updateProfile({
    required String username,
    String? avatarFilePath, // local path for multipart
  }) async {
    final url = Uri.parse('$baseUrl/profile');
    final token = await _getToken();
    final request = http.MultipartRequest('POST', url);
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['username'] = username;
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarFilePath));
    }
    try {
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return _ApiResponse(data: jsonDecode(resp.body));
      } else {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
        if (decoded is Map && decoded['message'] is String) {
          return _ApiResponse(error: decoded['message']);
        }
        return _ApiResponse(error: 'Unexpected error (${resp.statusCode}).');
      }
    } catch (_) {
      return _ApiResponse(error: 'Network error. Please check your connection.');
    }
  }

  Future<_ApiResponse> deleteAvatar() {
    return _request('DELETE', '/profile/avatar', auth: true);
  }

  Future<_ApiResponse> checkDeletePassword({required String password}) {
    return _request(
      'POST',
      '/auth/delete/check',
      auth: true,
      body: jsonEncode({'password': password}),
    );
  }

  Future<_ApiResponse> deleteAccount({required String password}) {
    return _request(
      'DELETE',
      '/auth/delete',
      auth: true,
      body: jsonEncode({'password': password}),
    );
  }

  Future<_ApiResponse> forgotPassword({required String email}) {
    return _request(
      'POST',
      '/password/forgot',
      body: jsonEncode({'email': email}),
    );
  }

  Future<_ApiResponse> verifyCode({
    required String email,
    required String code,
  }) {
    return _request(
      'POST',
      '/password/verify',
      body: jsonEncode({'email': email, 'code': code}),
    );
  }

  Future<_ApiResponse> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) {
    return _request(
      'POST',
      '/password/reset',
      body: jsonEncode({
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
  }

  // ===== Groups =====
  Future<_ApiResponse> getGroups() {
    return _request('GET', '/groups', auth: true);
  }

  Future<_ApiResponse> getGroupsExplore() {
    return _request('GET', '/groups/explore', auth: true);
  }

  Future<_ApiResponse> createGroup({
    required String name,
    String type = 'khitma',
    int? daysToComplete,
    String? startDate, // 'YYYY-MM-DD'
    int? membersTarget,
    bool isPublic = true,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'type': type,
      'is_public': isPublic,
    };
    if (daysToComplete != null) body['days_to_complete'] = daysToComplete;
    if (startDate != null) body['start_date'] = startDate;
    if (membersTarget != null) body['members_target'] = membersTarget;
    return _request('POST', '/groups', auth: true, body: jsonEncode(body));
  }

  Future<_ApiResponse> getGroup(int id) {
    return _request('GET', '/groups/$id', auth: true);
  }

  Future<_ApiResponse> getGroupInvite(int id) {
    return _request('GET', '/groups/$id/invite', auth: true);
  }

  Future<_ApiResponse> joinGroup({required String token}) {
    return _request('POST', '/groups/join', auth: true, body: jsonEncode({'token': token}));
  }

  Future<_ApiResponse> joinPublicGroup(int id) {
    return _request('POST', '/groups/$id/join', auth: true);
  }

  Future<_ApiResponse> leaveGroup(int id) {
    return _request('POST', '/groups/$id/leave', auth: true);
  }

  Future<_ApiResponse> removeGroupMember(int id, int userId) {
    return _request('DELETE', '/groups/$id/members/$userId', auth: true);
  }

  // ===== Khitma-specific =====
  Future<_ApiResponse> khitmaAutoAssign(int id) {
    return _request('POST', '/groups/$id/khitma/auto-assign', auth: true);
  }

  Future<_ApiResponse> khitmaManualAssign(int id, List<Map<String, dynamic>> assignments) {
    // assignments: [{ 'user_id': 1, 'juz_numbers': [1,2,3] }, ...]
    return _request('POST', '/groups/$id/khitma/manual-assign', auth: true, body: jsonEncode({'assignments': assignments}));
  }

  Future<_ApiResponse> khitmaAssignments(int id) {
    return _request('GET', '/groups/$id/khitma/assignments', auth: true);
  }

  Future<_ApiResponse> khitmaUpdateAssignment(
    int id, {
    required int juzNumber,
    String? status,
    int? pagesRead,
  }) {
    final body = <String, dynamic>{'juz_number': juzNumber};
    if (status != null) body['status'] = status;
    if (pagesRead != null) body['pages_read'] = pagesRead;
    return _request('PATCH', '/groups/$id/khitma/assignment', auth: true, body: jsonEncode(body));
  }
}

class _ApiResponse {
  final dynamic data;
  final String? error;
  _ApiResponse({this.data, this.error});
  bool get ok => error == null;
}
