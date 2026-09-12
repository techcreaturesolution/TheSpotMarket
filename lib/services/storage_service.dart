import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Local persistence for PAN profiles, allotment results and user settings.
/// PAN numbers stay on-device only; nothing is uploaded unless a backend
/// allotment check is explicitly configured.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kProfiles = 'pan_profiles';
  static const _kAllotments = 'allotment_results';
  static const _kWatchlist = 'ipo_watchlist';
  static const _kDarkMode = 'dark_mode';
  static const _kAiKey = 'ai_api_key';
  static const _kAiProvider = 'ai_provider';
  static const _kChatHistory = 'chat_history';

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  List<PanProfile> loadProfiles() => _loadList(_kProfiles, PanProfile.fromJson);

  Future<void> saveProfiles(List<PanProfile> profiles) =>
      _saveList(_kProfiles, profiles.map((p) => p.toJson()));

  List<AllotmentResult> loadAllotments() =>
      _loadList(_kAllotments, AllotmentResult.fromJson);

  Future<void> saveAllotments(List<AllotmentResult> results) =>
      _saveList(_kAllotments, results.map((r) => r.toJson()));

  Set<String> loadWatchlist() =>
      (_prefs.getStringList(_kWatchlist) ?? const []).toSet();

  Future<void> saveWatchlist(Set<String> ids) =>
      _prefs.setStringList(_kWatchlist, ids.toList());

  bool get darkMode => _prefs.getBool(_kDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _prefs.setBool(_kDarkMode, v);

  String? get aiApiKey => _prefs.getString(_kAiKey);
  Future<void> setAiApiKey(String? v) =>
      v == null || v.isEmpty ? _prefs.remove(_kAiKey) : _prefs.setString(_kAiKey, v);

  String? get aiProvider => _prefs.getString(_kAiProvider);
  Future<void> setAiProvider(String v) => _prefs.setString(_kAiProvider, v);

  List<ChatMessage> loadChat() => _loadList(
        _kChatHistory,
        (j) => ChatMessage(
          role: j['role'] as String,
          text: j['text'] as String,
          at: DateTime.parse(j['at'] as String),
        ),
      );

  Future<void> saveChat(List<ChatMessage> messages) => _saveList(
        _kChatHistory,
        messages.take(50).map((m) => {
              'role': m.role,
              'text': m.text,
              'at': m.at.toIso8601String(),
            }),
      );

  List<T> _loadList<T>(String key, T Function(Map<String, dynamic>) parse) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(parse)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(String key, Iterable<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items.toList()));
}
