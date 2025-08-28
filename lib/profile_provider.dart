import 'package:flutter/material.dart';
import 'services/api_client.dart';

class ProfileProvider extends ChangeNotifier {
  int? _id;
  String? _name; // display name (can be same as username for now)
  String? _username;
  String? _email;
  String? _avatarUrl;
  String? _joinedAt; // ISO string
  bool _loading = false;

  int? get id => _id;
  String? get name => _name;
  String? get username => _username;
  String? get email => _email;
  String? get avatarUrl => _avatarUrl;
  String? get joinedAt => _joinedAt;
  bool get loading => _loading;

  String get displayName {
    final n = (_name ?? '').trim();
    final u = (_username ?? '').trim();
    // Prefer username (handle) as the primary display to reflect edits immediately
    return u.isNotEmpty ? u : n;
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    final resp = await ApiClient.instance.me();
    if (resp.ok && resp.data is Map) {
      setFromMap(resp.data as Map<String, dynamic>);
    }
    _loading = false;
    notifyListeners();
  }

  void setFromMap(Map<String, dynamic> data) {
    _id = (data['id'] is int) ? data['id'] as int : int.tryParse('${data['id'] ?? ''}');
    _name = (data['name'] as String?)?.trim();
    _username = (data['username'] as String?)?.trim();
    _email = (data['email'] as String?)?.trim();
    _avatarUrl = (data['avatar_url'] as String?)?.trim();
    _joinedAt = (data['joined_at'] as String?)?.trim();
    notifyListeners();
  }

  void clear() {
    _id = null;
    _name = null;
    _username = null;
    _email = null;
    _avatarUrl = null;
    _joinedAt = null;
    notifyListeners();
  }
}
