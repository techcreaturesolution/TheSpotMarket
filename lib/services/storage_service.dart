import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Local persistence for PAN profiles, allotment results and user settings.
/// Sensitive PAN profiles are stored in encrypted local storage (FlutterSecureStorage).
/// Non-sensitive preferences (allotments, watchlist, dark mode) use SharedPreferences.
class StorageService {
  StorageService(this._prefs, {FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const _kProfiles = 'pan_profiles';
  static const _kSecureProfiles = 'secure_pan_profiles';
  static const _kAllotments = 'allotment_results';
  static const _kWatchlist = 'ipo_watchlist';
  static const _kDarkMode = 'dark_mode';
  static const _kAiKey = 'ai_api_key';
  static const _kAiProvider = 'ai_provider';
  static const _kChatHistory = 'chat_history';

  List<PanProfile> _cachedProfiles = const [];

  static Future<StorageService> create({
    SharedPreferences? prefs,
    FlutterSecureStorage? secureStorage,
  }) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final service = StorageService(p, secureStorage: secureStorage);
    await service._migrateAndLoadProfiles();
    return service;
  }

  Future<void> _migrateAndLoadProfiles() async {
    try {
      final rawSecure = await _secureStorage.read(key: _kSecureProfiles);
      if (rawSecure != null && rawSecure.isNotEmpty) {
        _cachedProfiles = (jsonDecode(rawSecure) as List)
            .cast<Map<String, dynamic>>()
            .map(PanProfile.fromJson)
            .toList();
        // Remove legacy unencrypted key if it exists
        if (_prefs.containsKey(_kProfiles)) {
          await _prefs.remove(_kProfiles);
        }
        return;
      }
    } catch (_) {}

    // Migration fallback: check legacy unencrypted SharedPreferences key
    final oldRaw = _prefs.getString(_kProfiles);
    if (oldRaw != null && oldRaw.isNotEmpty) {
      try {
        _cachedProfiles = (jsonDecode(oldRaw) as List)
            .cast<Map<String, dynamic>>()
            .map(PanProfile.fromJson)
            .toList();
        try {
          await _secureStorage.write(
            key: _kSecureProfiles,
            value: jsonEncode(_cachedProfiles.map((p) => p.toJson()).toList()),
          );
          await _prefs.remove(_kProfiles);
        } catch (_) {}
        return;
      } catch (_) {}
    }

    _cachedProfiles = const [];
  }

  List<PanProfile> loadProfiles() => List.unmodifiable(_cachedProfiles);

  Future<void> saveProfiles(List<PanProfile> profiles) async {
    _cachedProfiles = List.from(profiles);
    try {
      await _secureStorage.write(
        key: _kSecureProfiles,
        value: jsonEncode(profiles.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
    await _prefs.remove(_kProfiles);
  }

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

