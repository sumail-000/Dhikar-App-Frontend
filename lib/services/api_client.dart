import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // Compile-time default base (can be overridden at runtime via SharedPreferences)
  static final String _defaultRawBase = String.fromEnvironment('API_BASE', defaultValue: 'https://wered.devigncreatives.com/api');
  static String? _overrideRawBase; // persisted override (raw), may be null

  // Normalize API base: ensure it ends with /api to match Laravel route prefix
  static String _normalizeBase(String input) {
    var b = input.trim();
    // Remove trailing slash for consistency
    if (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    // Ensure /api suffix
    if (!b.toLowerCase().endsWith('/api')) {
      b = '$b/api';
    }
    return b;
  }

  // Current base URL (normalized) – prefers override if set
  String get currentBaseUrl => _normalizeBase((_overrideRawBase ?? _defaultRawBase));

  // Initialize override from storage (call at app start)
  Future<void> initBaseOverride() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('api_base_override');
    if (raw != null && raw.trim().isNotEmpty) {
      _overrideRawBase = raw;
    }
  }

  // Set or clear runtime override. Pass null/empty to clear.
  Future<void> setBaseOverride(String? newBase) async {
    final prefs = await SharedPreferences.getInstance();
    if (newBase == null || newBase.trim().isEmpty) {
      _overrideRawBase = null;
      await prefs.remove('api_base_override');
    } else {
      _overrideRawBase = newBase;
      await prefs.setString('api_base_override', newBase);
    }
  }

  // Helpful for debugging
  String get debugBaseInfo => 'default=' + _normalizeBase(_defaultRawBase) + ', override=' + (_overrideRawBase ?? 'null') + ', using=' + currentBaseUrl;

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
    final url = Uri.parse('${currentBaseUrl}$path');
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
          resp = await http.get(url, headers: defaultHeaders).timeout(Duration(seconds: 60));
          break;
        case 'POST':
          resp = await http.post(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 60));
          break;
        case 'PATCH':
          resp = await http.patch(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 60));
          break;
        case 'DELETE':
          resp = await http.delete(url, headers: defaultHeaders, body: body).timeout(Duration(seconds: 60));
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
    final url = Uri.parse('${currentBaseUrl}/profile');
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

  // ===== Dhikr Groups =====
  Future<_ApiResponse> getDhikrGroups() {
    return _request('GET', '/dhikr-groups', auth: true);
  }

  Future<_ApiResponse> getDhikrGroupsExplore() {
    return _request('GET', '/dhikr-groups/explore', auth: true);
  }

  Future<_ApiResponse> createDhikrGroup({
    required String name,
    int? daysToComplete,
    int? membersTarget,
    int? dhikrTarget,
    String? dhikrTitle,
    String? dhikrTitleArabic,
    bool isPublic = true,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'is_public': isPublic,
    };
    if (daysToComplete != null) body['days_to_complete'] = daysToComplete;
    if (membersTarget != null) body['members_target'] = membersTarget;
    if (dhikrTarget != null) body['dhikr_target'] = dhikrTarget;
    if (dhikrTitle != null && dhikrTitle.trim().isNotEmpty) body['dhikr_title'] = dhikrTitle.trim();
    if (dhikrTitleArabic != null && dhikrTitleArabic.trim().isNotEmpty) body['dhikr_title_arabic'] = dhikrTitleArabic.trim();
    return _request('POST', '/dhikr-groups', auth: true, body: jsonEncode(body));
  }

  Future<_ApiResponse> getDhikrGroup(int id) {
    return _request('GET', '/dhikr-groups/$id', auth: true);
  }

  Future<_ApiResponse> updateDhikrGroupPrivacy(int id, bool isPublic) {
    return _request('PATCH', '/dhikr-groups/$id', auth: true, body: jsonEncode({'is_public': isPublic}));
  }

  Future<_ApiResponse> getDhikrGroupInvite(int id) {
    return _request('GET', '/dhikr-groups/$id/invite', auth: true);
  }

  Future<_ApiResponse> joinDhikrGroup({required String token}) {
    return _request('POST', '/dhikr-groups/join', auth: true, body: jsonEncode({'token': token}));
  }

  Future<_ApiResponse> joinPublicDhikrGroup(int id) {
    return _request('POST', '/dhikr-groups/$id/join', auth: true);
  }

  Future<_ApiResponse> leaveDhikrGroup(int id) {
    return _request('POST', '/dhikr-groups/$id/leave', auth: true);
  }

  Future<_ApiResponse> removeDhikrGroupMember(int id, int userId) {
    return _request('DELETE', '/dhikr-groups/$id/members/$userId', auth: true);
  }

  Future<_ApiResponse> deleteDhikrGroup(int id) {
    return _request('DELETE', '/dhikr-groups/$id', auth: true);
  }

  // Dhikr progress
  Future<_ApiResponse> saveDhikrGroupProgress(int id, int count) {
    return _request('POST', '/dhikr-groups/$id/progress', auth: true, body: jsonEncode({'count': count}));
  }

  Future<_ApiResponse> getDhikrGroupProgress(int id) {
    return _request('GET', '/dhikr-groups/$id/progress', auth: true);
  }

  // ===== Motivation =====
  Future<_ApiResponse> getMotivation() {
    return _request('GET', '/motivation', auth: true);
  }

  // ===== Activity / Streak =====
  Future<_ApiResponse> activityPing() {
    return _request('POST', '/activity/ping', auth: true);
  }

  Future<_ApiResponse> activityReading() {
    return _request('POST', '/activity/reading', auth: true);
  }

  Future<_ApiResponse> getStreak() {
    return _request('GET', '/streak', auth: true);
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

  // ===== Custom Dhikr =====
  Future<_ApiResponse> getCustomDhikr() {
    return _request('GET', '/custom-dhikr', auth: true);
  }

  Future<_ApiResponse> createCustomDhikr({
    required String title,
    required String titleArabic,
    String? subtitle,
    String? subtitleArabic,
    required String arabic,
  }) {
    return _request(
      'POST',
      '/custom-dhikr',
      auth: true,
      body: jsonEncode({
        'title': title,
        'title_arabic': titleArabic,
        'subtitle': subtitle ?? '',
        'subtitle_arabic': subtitleArabic ?? subtitle ?? '',
        'arabic_text': arabic,
      }),
    );
  }

  Future<_ApiResponse> updateCustomDhikr({
    required int id,
    String? title,
    String? titleArabic,
    String? subtitle,
    String? subtitleArabic,
    String? arabic,
  }) {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (titleArabic != null) body['title_arabic'] = titleArabic;
    if (subtitle != null) body['subtitle'] = subtitle;
    if (subtitleArabic != null) body['subtitle_arabic'] = subtitleArabic;
    if (arabic != null) body['arabic_text'] = arabic;
    return _request('PATCH', '/custom-dhikr/$id', auth: true, body: jsonEncode(body));
  }

  Future<_ApiResponse> deleteCustomDhikr(int id) {
    return _request('DELETE', '/custom-dhikr/$id', auth: true);
  }

  // ===== Device Token Management =====
  Future<_ApiResponse> registerDevice({
    required String deviceToken,
    String? platform,
    String? locale,
    String? timezone,
  }) {
    final body = <String, dynamic>{
      'device_token': deviceToken,
    };
    if (platform != null) body['platform'] = platform;
    if (locale != null) body['locale'] = locale;
    if (timezone != null) body['timezone'] = timezone;

    return _request('POST', '/devices/register', auth: true, body: jsonEncode(body));
  }

  Future<_ApiResponse> unregisterDevice({
    required String deviceToken,
  }) {
    return _request(
      'POST',
      '/devices/unregister',
      auth: true,
      body: jsonEncode({'device_token': deviceToken})
    );
  }

  // ===== User Preferences =====
  Future<_ApiResponse> getUserPreferences() {
    return _request('GET', '/user/preferences', auth: true);
  }

  Future<_ApiResponse> updateUserPreferences({
    bool? allowGroup,
    bool? allowMotivational,
    bool? allowPersonal,
    String? preferredHour, // '00'..'23'
  }) {
    final body = <String, dynamic>{};
    if (allowGroup != null) body['allow_group_notifications'] = allowGroup;
    if (allowMotivational != null) body['allow_motivational_notifications'] = allowMotivational;
    if (allowPersonal != null) body['allow_personal_reminders'] = allowPersonal;
    if (preferredHour != null) body['preferred_personal_reminder_hour'] = preferredHour;
    return _request('PUT', '/user/preferences', auth: true, body: jsonEncode(body));
  }

  // ===== In-App Notifications =====
  Future<_ApiResponse> getNotifications() {
    return _request('GET', '/notifications', auth: true);
  }

  Future<_ApiResponse> markNotificationAsRead(int notificationId) {
    return _request(
      'PATCH',
      '/notifications/$notificationId/read',
      auth: true,
      body: jsonEncode({'read': true})
    );
  }

  Future<_ApiResponse> deleteNotification(int notificationId) {
    return _request('DELETE', '/notifications/$notificationId', auth: true);
  }

  // ===== Group Admin Reminders =====
  Future<_ApiResponse> sendGroupReminder(int groupId, String message) {
    return _request(
      'POST',
      '/groups/$groupId/reminders',
      auth: true,
      body: jsonEncode({'message': message})
    );
  }

  Future<_ApiResponse> sendGroupMemberReminder(int groupId, int userId, String message) {
    return _request(
      'POST',
      '/groups/$groupId/reminders/member',
      auth: true,
      body: jsonEncode({'user_id': userId, 'message': message}),
    );
  }

  Future<_ApiResponse> sendDhikrGroupReminder(int dhikrGroupId, String message) {
    return _request(
      'POST',
      '/dhikr-groups/$dhikrGroupId/reminders',
      auth: true,
      body: jsonEncode({'message': message})
    );
  }

  Future<_ApiResponse> sendDhikrGroupMemberReminder(int groupId, int userId, String message) {
    return _request(
      'POST',
      '/dhikr-groups/$groupId/reminders/member',
      auth: true,
      body: jsonEncode({'user_id': userId, 'message': message}),
    );
  }

  // ===== Network Diagnostics =====

  // ===== Push tracking =====
  Future<_ApiResponse> pushReceived({
    String? notificationType,
    String? deviceToken,
    Map<String, dynamic>? data,
    String? title,
    String? body,
  }) {
    final payload = <String, dynamic>{};
    if (notificationType != null) payload['notification_type'] = notificationType;
    if (deviceToken != null) payload['device_token'] = deviceToken;
    if (data != null) payload['data'] = data;
    if (title != null) payload['title'] = title;
    if (body != null) payload['body'] = body;
    return _request('POST', '/push/received', auth: true, body: jsonEncode(payload));
  }

  Future<_ApiResponse> pushOpened({
    String? notificationType,
    String? deviceToken,
    Map<String, dynamic>? data,
    String? title,
    String? body,
  }) {
    final payload = <String, dynamic>{};
    if (notificationType != null) payload['notification_type'] = notificationType;
    if (deviceToken != null) payload['device_token'] = deviceToken;
    if (data != null) payload['data'] = data;
    if (title != null) payload['title'] = title;
    if (body != null) payload['body'] = body;
    return _request('POST', '/push/opened', auth: true, body: jsonEncode(payload));
  }
}

class _ApiResponse {
  final dynamic data;
  final String? error;
  _ApiResponse({this.data, this.error});
  bool get ok => error == null;
}
