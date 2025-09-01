import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

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
      print('🌐 Making HTTP request...');
      switch (method) {
        case 'GET':
          resp = await http.get(url, headers: defaultHeaders).timeout(Duration(seconds: 10));
          break;
        case 'POST':
          resp = await http.post(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 10));
          break;
        case 'PATCH':
          resp = await http.patch(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 10));
          break;
        case 'DELETE':
          resp = await http.delete(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported method');
      }
      print('✅ HTTP request completed - Status: ${resp.statusCode}');
      print('📤 Response body length: ${resp.body.length}');
      if (resp.statusCode >= 400) {
        print('❌ Error response body: ${resp.body}');
      }
    } catch (e, stackTrace) {
      print('❌ HTTP request failed with error: $e');
      print('📍 Stack trace: $stackTrace');
      if (e.toString().contains('TimeoutException')) {
        return _ApiResponse(error: 'Request timeout. Please check your connection and try again.');
      }
      return _ApiResponse(error: 'Network error: ${e.toString()}. Please check your connection.');
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

  Future<_ApiResponse> updateGroupPrivacy(int id, bool isPublic) {
    return _request('PATCH', '/groups/$id', auth: true, body: jsonEncode({'is_public': isPublic}));
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

  Future<_ApiResponse> deleteGroup(int id) {
    return _request('DELETE', '/groups/$id', auth: true);
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

  // Quran/Juz meta (Uthmani Hafs)
  Future<_ApiResponse> khitmaJuzPages() {
    return _request('GET', '/khitma/juz-pages', auth: true);
  }

  // ===== Personal Khitma =====

  /// Get all personal khitmas for current user
  Future<_ApiResponse> getPersonalKhitmas() {
    return _request('GET', '/personal-khitma', auth: true);
  }

  /// Create a new personal khitma
  Future<_ApiResponse> createPersonalKhitma({
    required String khitmaName,
    required int totalDays,
    String? startDate, // 'YYYY-MM-DD' format
  }) {
    final body = <String, dynamic>{
      'khitma_name': khitmaName,
      'total_days': totalDays,
    };
    if (startDate != null) body['start_date'] = startDate;
    return _request('POST', '/personal-khitma', auth: true, body: jsonEncode(body));
  }

  /// Get specific personal khitma details
  Future<_ApiResponse> getPersonalKhitma(int id) {
    return _request('GET', '/personal-khitma/$id', auth: true);
  }

  /// Save reading progress for a personal khitma
  Future<_ApiResponse> savePersonalKhitmaProgress({
    required int khitmaId,
    required int juzzRead,
    required int surahRead,
    required int startPage,
    required int endPage,
    int? startVerse,
    int? endVerse,
    int? readingDurationMinutes,
    String? notes,
  }) {
    final body = <String, dynamic>{
      'juzz_read': juzzRead,
      'surah_read': surahRead,
      'start_page': startPage,
      'end_page': endPage,
    };
    if (startVerse != null) body['start_verse'] = startVerse;
    if (endVerse != null) body['end_verse'] = endVerse;
    if (readingDurationMinutes != null) body['reading_duration_minutes'] = readingDurationMinutes;
    if (notes != null) body['notes'] = notes;

    return _request('POST', '/personal-khitma/$khitmaId/progress', auth: true, body: jsonEncode(body));
  }

  /// Update personal khitma status (active/paused/completed)
  Future<_ApiResponse> updatePersonalKhitmaStatus({
    required int khitmaId,
    required String status, // 'active', 'paused', or 'completed'
  }) {
    return _request('PATCH', '/personal-khitma/$khitmaId/status', auth: true, body: jsonEncode({
      'status': status,
    }));
  }

  /// Delete a personal khitma
  Future<_ApiResponse> deletePersonalKhitma(int khitmaId) {
    return _request('DELETE', '/personal-khitma/$khitmaId', auth: true);
  }

  /// Get reading statistics for a personal khitma
  Future<_ApiResponse> getPersonalKhitmaStatistics(int khitmaId) {
    return _request('GET', '/personal-khitma/$khitmaId/statistics', auth: true);
  }

  /// Get user's active personal khitma (if any)
  Future<_ApiResponse> getActivePersonalKhitma() {
    return _request('GET', '/personal-khitma/active', auth: true);
  }

  /// Save reading progress for a group khitma
  Future<_ApiResponse> saveGroupKhitmaProgress({
    required int groupId,
    required int juzzRead,
    required int surahRead,
    required int pageRead,
    int? startVerse,
    int? endVerse,
    String? notes,
  }) {
    final body = <String, dynamic>{
      'juzz_read': juzzRead,
      'surah_read': surahRead,
      'page_read': pageRead,
    };
    if (startVerse != null) body['start_verse'] = startVerse;
    if (endVerse != null) body['end_verse'] = endVerse;
    if (notes != null) body['notes'] = notes;

    return _request('POST', '/groups/$groupId/khitma/progress', auth: true, body: jsonEncode(body));
  }

  /// Get user's total group khitma statistics across all groups
  Future<_ApiResponse> getUserGroupKhitmaStats() {
    return _request('GET', '/user/group-khitma-stats', auth: true);
  }

  // ===== Network Diagnostics =====
  
  /// Test basic connectivity to the server
  Future<Map<String, dynamic>> testConnectivity() async {
    final stopwatch = Stopwatch()..start();
    print('🔍 Testing network connectivity...');
    
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': baseUrl,
    };
    
    // Test 1: Basic URL parsing
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      results['urlParsing'] = {
        'success': true,
        'host': url.host,
        'port': url.port,
        'scheme': url.scheme,
      };
      print('✅ URL parsing: ${url.host}:${url.port}');
    } catch (e) {
      results['urlParsing'] = {
        'success': false,
        'error': e.toString(),
      };
      print('❌ URL parsing failed: $e');
    }
    
    // Test 2: Socket connection
    try {
      print('🔌 Testing socket connection to 192.168.1.5:8000...');
      final socket = await Socket.connect('192.168.1.5', 8000, timeout: Duration(seconds: 5));
      await socket.close();
      results['socketConnection'] = {
        'success': true,
        'latency': stopwatch.elapsedMilliseconds,
      };
      print('✅ Socket connection successful (${stopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
      results['socketConnection'] = {
        'success': false,
        'error': e.toString(),
        'latency': stopwatch.elapsedMilliseconds,
      };
      print('❌ Socket connection failed: $e');
    }
    
    // Test 3: Simple HTTP GET
    stopwatch.reset();
    try {
      print('🌐 Testing HTTP GET request...');
      final response = await http.get(
        Uri.parse('http://192.168.1.5:8000/api/auth/register'),
        headers: {'Accept': 'application/json'}
      ).timeout(Duration(seconds: 10));
      results['httpTest'] = {
        'success': true,
        'statusCode': response.statusCode,
        'latency': stopwatch.elapsedMilliseconds,
        'contentLength': response.body.length,
        'headers': response.headers,
      };
      print('✅ HTTP test: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
      results['httpTest'] = {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'latency': stopwatch.elapsedMilliseconds,
      };
      print('❌ HTTP test failed: $e (Type: ${e.runtimeType})');
    }
    
    stopwatch.stop();
    results['totalTime'] = stopwatch.elapsedMilliseconds;
    print('🏁 Network diagnostic completed in ${stopwatch.elapsedMilliseconds}ms');
    
    return results;
  }
  
  /// Test authentication endpoints specifically
  Future<Map<String, dynamic>> testAuthEndpoints() async {
    print('🔐 Testing authentication endpoints...');
    final results = <String, dynamic>{};
    
    // Test register endpoint with invalid data (should get validation error, not network error)
    try {
      print('📝 Testing registration endpoint...');
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8000/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': 'test',
          'email': 'invalid-email', // This should trigger validation error
          'password': '123' // Too short, should trigger validation error
        })
      ).timeout(Duration(seconds: 10));
      
      results['registerTest'] = {
        'success': true,
        'statusCode': response.statusCode,
        'body': response.body,
        'reachable': true,
      };
      print('✅ Register endpoint reachable: ${response.statusCode}');
    } catch (e) {
      results['registerTest'] = {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'reachable': false,
      };
      print('❌ Register endpoint failed: $e');
    }
    
    return results;
  }
}

class _ApiResponse {
  final dynamic data;
  final String? error;
  _ApiResponse({this.data, this.error});
  bool get ok => error == null;
}
