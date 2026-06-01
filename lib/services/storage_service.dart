import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'birth_year_vault.dart';

class StorageService {
  static const String _profileKey = 'user_profile';
  static const String _onboardedKey = 'is_onboarded';
  static const String _lastCardDateKey = 'last_card_date';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> isOnboarded() async {
    final prefs = await _preferences();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await _preferences();
    await prefs.setBool(_onboardedKey, true);
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _preferences();
    await BirthYearVault.save(profile.birthYear);
    await prefs.setString(_profileKey, jsonEncode(profile.toPrefsJson()));
  }

  static Future<UserProfile?> loadProfile() async {
    final prefs = await _preferences();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _profileFromStoredJson(prefs, json);
    } catch (_) {
      return null;
    }
  }

  static Future<UserProfile?> _profileFromStoredJson(
    SharedPreferences prefs,
    Map<String, dynamic> json,
  ) async {
    if (json.containsKey('dob')) {
      final legacy = DateTime.parse(json['dob'] as String);
      await BirthYearVault.save(legacy.year);
      json.remove('dob');
      json['birthMonth'] = legacy.month;
      json['birthDay'] = legacy.day;
      await prefs.setString(_profileKey, jsonEncode(json));
    }

    final birthYear = await BirthYearVault.read();
    if (birthYear == null) return null;

    if (!json.containsKey('birthMonth') || !json.containsKey('birthDay')) {
      return null;
    }

    return UserProfile.fromPrefsJson(json, birthYear: birthYear);
  }

  static Future<String?> lastCardDate() async {
    final prefs = await _preferences();
    return prefs.getString(_lastCardDateKey);
  }

  static Future<void> saveLastCardDate(DateTime date) async {
    final prefs = await _preferences();
    await prefs.setString(
      _lastCardDateKey,
      '${date.year}-${date.month}-${date.day}',
    );
  }

  static Future<bool> hasCardForToday() async {
    final last = await lastCardDate();
    if (last == null) return false;
    final now = DateTime.now();
    return last == '${now.year}-${now.month}-${now.day}';
  }

  /// Clears profile and vault (e.g. debug / reset onboarding).
  static Future<void> clearAll() async {
    final prefs = await _preferences();
    await prefs.clear();
    _prefs = null;
    await BirthYearVault.delete();
  }
}
